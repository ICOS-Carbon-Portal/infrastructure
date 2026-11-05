#!/usr/bin/env python3
"""Install new Lantmäteriet GeoPackage deliveries for MapProxy.

Usage: refresh.py refresh.json
"""

import base64
import hashlib
import json
import logging
import os
import posixpath
import random
import re
import sqlite3
import struct
import subprocess
import sys
import tempfile
import time
import urllib.parse
import urllib.request
from pathlib import Path

log = logging.getLogger("refresh")

GIB = 1024**3
PROBE_BYTES = 256 * 1024
DOWNLOAD_ATTEMPTS = 5
PNG_MAGIC = b"\x89PNG\r\n\x1a\n"
PNG_END = b"IEND\xaeB`\x82"


class Rejected(Exception):
    pass


def access_token(cfg):
    credentials = base64.b64encode(f"{cfg['client_id']}:{cfg['client_secret']}".encode()).decode()
    request = urllib.request.Request(
        cfg["token_url"],
        data=b"grant_type=client_credentials",
        headers={"Authorization": f"Basic {credentials}"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)["access_token"]


def remote_file(cfg, layer):
    with urllib.request.urlopen(cfg["stac_items_url"], timeout=60) as response:
        items = [item for item in json.load(response)["features"] if item["id"] == layer["stac_item"]]
    if len(items) != 1:
        raise RuntimeError(f"expected one STAC item {layer['stac_item']!r}, found {len(items)}")
    asset = items[0]["assets"]["data"]
    return asset["href"], asset["file:checksum"], asset["file:size"]


def fetch_head(cfg, url, nbytes):
    request = urllib.request.Request(
        url,
        headers={"Authorization": f"Bearer {access_token(cfg)}", "Range": f"bytes=0-{nbytes - 1}"},
    )
    with urllib.request.urlopen(request, timeout=300) as response:
        return response.read(nbytes)


def checksum_matches(path, checksum):
    # A multihash: 0x12 is SHA-256, 0x20 its length in bytes.
    if not checksum.startswith("1220"):
        raise RuntimeError(f"unsupported checksum {checksum}")
    sha256 = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(1024 * 1024):
            sha256.update(chunk)
    return sha256.hexdigest() == checksum[4:]


def page_size_of(header):
    page_size = struct.unpack_from(">H", header, 16)[0]
    return 65536 if page_size == 1 else page_size


def check_contents(db, grid, table_name):
    rows = db.execute(
        "SELECT table_name, srs_id, min_x, min_y, max_x, max_y, last_change"
        " FROM gpkg_contents WHERE data_type = 'tiles'"
    ).fetchall()
    if len(rows) != 1 or rows[0][0] != table_name:
        raise Rejected(f"expected one tiles table {table_name!r} in gpkg_contents, found {rows}")
    _, srs_id, *bbox, last_change = rows[0]
    if srs_id != grid["srs_id"]:
        raise Rejected(f"gpkg_contents srs_id is {srs_id}, expected {grid['srs_id']}")
    if bbox != grid["bbox"]:
        raise Rejected(f"gpkg_contents bbox is {bbox}, expected {grid['bbox']}")
    return last_change


def generation_of(last_change):
    digits = re.sub(r"\D", "", last_change)[:14]
    if len(digits) != 14:
        raise Rejected(f"cannot parse last_change {last_change!r}")
    return f"{digits[:8]}T{digits[8:]}"


def probe_generation(head, grid, table_name):
    if not head.startswith(b"SQLite format 3\0"):
        raise Rejected("not an SQLite file")
    page_size = page_size_of(head)
    pages = len(head) // page_size
    truncated = bytearray(head[: pages * page_size])
    # The header's page count covers the whole file; SQLite refuses the truncated copy unless
    # it matches the pages present. The metadata tables are in the first pages.
    struct.pack_into(">I", truncated, 28, pages)
    with tempfile.NamedTemporaryFile(suffix=".gpkg") as tmp:
        tmp.write(truncated)
        tmp.flush()
        db = sqlite3.connect(f"file:{tmp.name}?mode=ro", uri=True)
        try:
            return generation_of(check_contents(db, grid, table_name))
        finally:
            db.close()


def validate(path, grid, table_name, expected_size, sample_tiles):
    size = path.stat().st_size
    if size != expected_size:
        raise Rejected(f"size is {size}, expected {expected_size}")
    with open(path, "rb") as f:
        header = f.read(100)
    if not header.startswith(b"SQLite format 3\0"):
        raise Rejected("not an SQLite file")
    page_count = struct.unpack_from(">I", header, 28)[0]
    if page_size_of(header) * page_count != size:
        raise Rejected(f"SQLite header says {page_count} pages, which does not match the size")

    db = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    try:
        check_contents(db, grid, table_name)

        matrix_set = db.execute(
            "SELECT srs_id, min_x, min_y, max_x, max_y FROM gpkg_tile_matrix_set WHERE table_name = ?",
            (table_name,),
        ).fetchall()
        if matrix_set != [(grid["srs_id"], *grid["bbox"])]:
            raise Rejected(f"gpkg_tile_matrix_set is {matrix_set}")

        matrix = db.execute(
            "SELECT zoom_level, tile_width, tile_height, pixel_x_size, pixel_y_size"
            " FROM gpkg_tile_matrix WHERE table_name = ? ORDER BY zoom_level",
            (table_name,),
        ).fetchall()
        tile_width, tile_height = grid["tile_size"]
        expected = [(zoom, tile_width, tile_height, res) for zoom, res in enumerate(grid["res"])]
        actual = [row[:3] for row in matrix]
        if actual != [row[:3] for row in expected] or any(
            abs(x - res) > 1e-6 or abs(y - res) > 1e-6
            for (*_, x, y), (*_, res) in zip(matrix, expected)
        ):
            raise Rejected(f"gpkg_tile_matrix does not match the grid: {matrix}")

        max_rowid = db.execute(f'SELECT max(rowid) FROM "{table_name}"').fetchone()[0]
        if not max_rowid:
            raise Rejected("no tiles")
        for _ in range(sample_tiles):
            row = db.execute(
                f'SELECT rowid, tile_data FROM "{table_name}" WHERE rowid >= ? ORDER BY rowid LIMIT 1',
                (random.randint(1, max_rowid),),
            ).fetchone()
            if not row[1].startswith(PNG_MAGIC) or not row[1].endswith(PNG_END):
                raise Rejected(f"tile rowid {row[0]} is not a complete PNG")
    finally:
        db.close()


def download(cfg, url, part, size):
    downloaded = part.stat().st_size if part.exists() else 0
    if downloaded > size:
        raise RuntimeError(f"{part} is larger than the remote file; delete it to start over")
    # A complete .part, left by a run that stopped before installing it, skips wget.
    # Access tokens expire after an hour, so a long download is resumed with a new one.
    while downloaded < size:
        if downloaded == 0:
            log.info("downloading %s (%.1f GiB)", url, size / GIB)
        else:
            log.info("downloading %s, resuming at %.1f of %.1f GiB", url, downloaded / GIB, size / GIB)
        # In a wgetrc rather than on the command line, where any user could read the token.
        with tempfile.NamedTemporaryFile("w", suffix=".wgetrc") as wgetrc:
            wgetrc.write(f"header = Authorization: Bearer {access_token(cfg)}\n")
            wgetrc.flush()
            subprocess.run(
                [
                    "wget", "--continue", "--no-verbose",
                    f"--limit-rate={int(cfg['rate_limit_mb'] * 1e6)}",
                    f"--tries={DOWNLOAD_ATTEMPTS}", "--waitretry=60",
                    f"--output-document={part}",
                    url,
                ],
                env={**os.environ, "WGETRC": wgetrc.name},
            )
        previous, downloaded = downloaded, part.stat().st_size if part.exists() else 0
        if downloaded == previous:
            raise RuntimeError(f"download stopped at {downloaded} of {size} bytes")
    if downloaded != size:
        raise RuntimeError(f"download incomplete: {downloaded} of {size} bytes")


def make_room(layer_dir, keep):
    for gen_dir in layer_dir.iterdir():
        if not gen_dir.is_dir() or gen_dir.is_symlink() or gen_dir.name in keep:
            continue
        log.info("removing old generation %s", gen_dir)
        for file in gen_dir.iterdir():
            if file.suffix in (".gpkg", ".part"):
                file.unlink()
        gen_dir.rmdir()


def tile_url(cfg, layer):
    tile = cfg["grids"][layer["grid"]]["verify_tile"]
    return (
        f"http://localhost:{cfg['port']}/wmts/{layer['name']}/{layer['grid']}"
        f"/{tile['zoom']}/{tile['col']}/{tile['row']}.png"
    )


def stored_tile(cfg, layer):
    tile = cfg["grids"][layer["grid"]]["verify_tile"]
    db = sqlite3.connect(f"file:{cfg['data']}/{layer['dir']}/current.gpkg?mode=ro", uri=True)
    try:
        return db.execute(
            f'SELECT tile_data FROM "{layer["table_name"]}"'
            " WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?",
            (tile["zoom"], tile["col"], tile["row"]),
        ).fetchone()[0]
    finally:
        db.close()


def restart_mapproxy(cfg, layer):
    subprocess.run(
        ["docker", "compose", "-f", f"{cfg['home']}/docker-compose.yml", "up", "-d", "--force-recreate", "mapproxy"],
        check=True,
    )
    deadline = time.monotonic() + 120
    expected = stored_tile(cfg, layer)
    while True:
        try:
            with urllib.request.urlopen(tile_url(cfg, layer), timeout=10) as response:
                if response.read() == expected:
                    break
        except OSError:
            pass
        if time.monotonic() > deadline:
            raise RuntimeError(f"MapProxy is not serving {layer['dir']}; see ops-mapproxy rollback")
        time.sleep(5)
    log.info("%s: MapProxy is serving it", layer["dir"])


def write_seen(path, **seen):
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(seen, indent=2) + "\n")
    os.replace(tmp, path)


def refresh_layer(cfg, layer):
    grid, table_name = cfg["grids"][layer["grid"]], layer["table_name"]
    layer_dir = Path(cfg["data"]) / layer["dir"]
    current = layer_dir / "current.gpkg"
    seen_path = layer_dir / "seen.json"
    seen = json.loads(seen_path.read_text()) if seen_path.exists() else {}
    installed = Path(os.readlink(current)).parts[0] if current.is_symlink() else None

    url, checksum, size = remote_file(cfg, layer)
    if (seen.get("checksum"), seen.get("size")) == (checksum, size):
        log.info("%s: %s", layer["dir"], "previously rejected" if seen.get("rejected") else "up to date")
        return False

    try:
        generation = probe_generation(fetch_head(cfg, url, PROBE_BYTES), grid, table_name)
    except Rejected:
        write_seen(seen_path, checksum=checksum, size=size, generation=None, rejected=True)
        raise
    if generation == installed:
        log.info("%s: republished with unchanged content (%s)", layer["dir"], generation)
        write_seen(seen_path, checksum=checksum, size=size, generation=generation, rejected=False)
        return False

    log.info("%s: new generation %s (installed: %s)", layer["dir"], generation, installed)
    make_room(layer_dir, keep={installed, generation})
    gen_dir = layer_dir / generation
    gen_dir.mkdir(exist_ok=True)
    final = gen_dir / posixpath.basename(urllib.parse.urlparse(url).path)
    part = final.with_name(final.name + ".part")

    if not final.exists():
        part_size = part.stat().st_size if part.exists() else 0
        stat = os.statvfs(layer_dir)
        needed = size - part_size + cfg["reserve_gib"] * GIB
        if stat.f_bavail * stat.f_frsize < needed:
            raise RuntimeError(f"not enough space in {layer_dir}, need {needed / GIB:.1f} GiB")

        download(cfg, url, part, size)
        if remote_file(cfg, layer) != (url, checksum, size):
            part.unlink()
            raise RuntimeError("remote file changed during download, discarded")
        if not checksum_matches(part, checksum):
            part.unlink()
            raise RuntimeError("checksum does not match the STAC item, discarded")
        try:
            validate(part, grid, table_name, size, cfg["sample_tiles"])
        except Rejected:
            part.unlink()
            write_seen(seen_path, checksum=checksum, size=size, generation=generation, rejected=True)
            raise
        os.rename(part, final)

    tmp_link = layer_dir / "current.gpkg.tmp"
    if tmp_link.is_symlink():
        tmp_link.unlink()
    os.symlink(final.relative_to(layer_dir), tmp_link)
    os.replace(tmp_link, current)
    write_seen(seen_path, checksum=checksum, size=size, generation=generation, rejected=False)
    log.info("%s: installed %s", layer["dir"], generation)
    if installed is None:
        # The playbook leaves this layer out of mapproxy.yaml until its first GeoPackage is here.
        log.info("%s: first delivery; run the playbook to start serving it", layer["dir"])
    else:
        restart_mapproxy(cfg, layer)
    return True


def main():
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    cfg = json.loads(Path(sys.argv[1]).read_text())
    # /data is mounted with nofail; without it, a download would fill the root disk.
    if not os.path.ismount(cfg["data_mount"]):
        log.error("%s is not mounted", cfg["data_mount"])
        return 1

    # At most one download per run, so that a release is spread over several nights.
    for layer in cfg["layers"]:
        try:
            if refresh_layer(cfg, layer):
                log.info("stopping after one download; any further layers are left for the next run")
                return 0
        except Exception:
            log.exception("%s: failed", layer["dir"])
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
