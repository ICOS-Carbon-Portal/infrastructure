#!/usr/bin/env python3
"""Install new Lantmäteriet GeoPackage deliveries for MapProxy.

Usage: refresh.py refresh.json
"""

import ftplib
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


def ftp_connect(host):
    ftp = ftplib.FTP(host, timeout=300)
    ftp.login()
    return ftp


def remote_file(host, remote_dir):
    ftp = ftp_connect(host)
    try:
        names = [posixpath.basename(n) for n in ftp.nlst(remote_dir) if n.endswith(".gpkg")]
        if len(names) != 1:
            raise RuntimeError(f"expected one .gpkg in {remote_dir}, found {names}")
        path = posixpath.join(remote_dir, names[0])
        # The server refuses SIZE in ASCII mode, and nlst() has just switched to it.
        ftp.voidcmd("TYPE I")
        mdtm = ftp.voidcmd(f"MDTM {path}").split()[1]
        size = ftp.size(path)
        ftp.quit()
    finally:
        ftp.close()
    return path, mdtm, size


def fetch_head(host, path, nbytes):
    ftp = ftp_connect(host)
    data = bytearray()
    try:
        ftp.voidcmd("TYPE I")
        with ftp.transfercmd(f"RETR {path}") as conn:
            while len(data) < nbytes:
                chunk = conn.recv(65536)
                if not chunk:
                    break
                data += chunk
    finally:
        # The transfer was cut short, so the control connection is not reusable.
        ftp.close()
    return bytes(data[:nbytes])


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


def download(host, path, part, size, rate_limit_mb):
    offset = part.stat().st_size if part.exists() else 0
    if offset > size:
        raise RuntimeError(f"{part} is larger than the remote file; delete it to start over")
    if offset < size:
        log.info("downloading %s from %.1f GiB of %.1f GiB", path, offset / GIB, size / GIB)
        subprocess.run(
            [
                "wget", "--continue", "--no-verbose",
                f"--limit-rate={int(rate_limit_mb * 1e6)}",
                f"--tries={DOWNLOAD_ATTEMPTS}", "--waitretry=60",
                f"--output-document={part}",
                f"ftp://{host}{path}",
            ],
            check=True,
        )
    offset = part.stat().st_size
    if offset != size:
        raise RuntimeError(f"download incomplete: {offset} of {size} bytes")


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
    tile = cfg["verify_tile"]
    return (
        f"http://localhost:{cfg['port']}/wmts/{layer['name']}/{cfg['grid']['name']}"
        f"/{tile['zoom']}/{tile['col']}/{tile['row']}.png"
    )


def stored_tile(cfg, layer):
    tile = cfg["verify_tile"]
    db = sqlite3.connect(f"file:{cfg['data']}/{layer['dir']}/current.gpkg?mode=ro", uri=True)
    try:
        return db.execute(
            f'SELECT tile_data FROM "{layer["table_name"]}"'
            " WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?",
            (tile["zoom"], tile["col"], tile["row"]),
        ).fetchone()[0]
    finally:
        db.close()


def restart_mapproxy(cfg):
    missing = [l["dir"] for l in cfg["layers"] if not (Path(cfg["data"]) / l["dir"] / "current.gpkg").exists()]
    if missing:
        # MapProxy fails to start while any configured GeoPackage is missing.
        log.info("not starting MapProxy yet, no current.gpkg for %s", ", ".join(missing))
        return
    subprocess.run(
        ["docker", "compose", "-f", f"{cfg['home']}/docker-compose.yml", "up", "-d", "--force-recreate", "mapproxy"],
        check=True,
    )
    deadline = time.monotonic() + 120
    for layer in cfg["layers"]:
        expected = stored_tile(cfg, layer)
        while True:
            try:
                with urllib.request.urlopen(tile_url(cfg, layer), timeout=10) as response:
                    if response.read() == expected:
                        break
            except OSError:
                pass
            if time.monotonic() > deadline:
                raise RuntimeError(f"MapProxy is not serving {layer['name']}; see ops-mapproxy rollback")
            time.sleep(5)
    log.info("MapProxy is serving all layers")


def write_seen(path, **seen):
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(seen, indent=2) + "\n")
    os.replace(tmp, path)


def refresh_layer(cfg, layer):
    grid, table_name = cfg["grid"], layer["table_name"]
    layer_dir = Path(cfg["data"]) / layer["dir"]
    current = layer_dir / "current.gpkg"
    seen_path = layer_dir / "seen.json"
    seen = json.loads(seen_path.read_text()) if seen_path.exists() else {}
    installed = Path(os.readlink(current)).parts[0] if current.is_symlink() else None

    path, mdtm, size = remote_file(cfg["ftp_host"], layer["remote_dir"])
    if (seen.get("mdtm"), seen.get("size")) == (mdtm, size):
        log.info("%s: %s", layer["name"], "previously rejected" if seen.get("rejected") else "up to date")
        return False

    try:
        generation = probe_generation(fetch_head(cfg["ftp_host"], path, PROBE_BYTES), grid, table_name)
    except Rejected:
        write_seen(seen_path, mdtm=mdtm, size=size, generation=None, rejected=True)
        raise
    if generation == installed:
        log.info("%s: republished with unchanged content (%s)", layer["name"], generation)
        write_seen(seen_path, mdtm=mdtm, size=size, generation=generation, rejected=False)
        return False

    log.info("%s: new generation %s (installed: %s)", layer["name"], generation, installed)
    make_room(layer_dir, keep={installed, generation})
    gen_dir = layer_dir / generation
    gen_dir.mkdir(exist_ok=True)
    final = gen_dir / posixpath.basename(path)
    part = final.with_name(final.name + ".part")

    if not final.exists():
        part_size = part.stat().st_size if part.exists() else 0
        stat = os.statvfs(layer_dir)
        needed = size - part_size + cfg["reserve_gib"] * GIB
        if stat.f_bavail * stat.f_frsize < needed:
            raise RuntimeError(f"not enough space in {layer_dir}, need {needed / GIB:.1f} GiB")

        download(cfg["ftp_host"], path, part, size, cfg["rate_limit_mb"])
        if remote_file(cfg["ftp_host"], layer["remote_dir"]) != (path, mdtm, size):
            part.unlink()
            raise RuntimeError("remote file changed during download, discarded")
        try:
            validate(part, grid, table_name, size, cfg["sample_tiles"])
        except Rejected:
            part.unlink()
            write_seen(seen_path, mdtm=mdtm, size=size, generation=generation, rejected=True)
            raise
        os.rename(part, final)

    tmp_link = layer_dir / "current.gpkg.tmp"
    if tmp_link.is_symlink():
        tmp_link.unlink()
    os.symlink(final.relative_to(layer_dir), tmp_link)
    os.replace(tmp_link, current)
    write_seen(seen_path, mdtm=mdtm, size=size, generation=generation, rejected=False)
    log.info("%s: installed %s", layer["name"], generation)
    return True


def main():
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    cfg = json.loads(Path(sys.argv[1]).read_text())
    # /data is mounted with nofail; without it, a download would fill the root disk.
    if not os.path.ismount(cfg["data_mount"]):
        log.error("%s is not mounted", cfg["data_mount"])
        return 1

    failed = False
    for layer in cfg["layers"]:
        try:
            if refresh_layer(cfg, layer):
                restart_mapproxy(cfg)
        except Exception:
            log.exception("%s: failed", layer["name"])
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
