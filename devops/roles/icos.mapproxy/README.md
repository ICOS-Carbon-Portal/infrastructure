# icos.mapproxy

Serves Lantmäteriet's *Topografisk webbkarta* (colour and grey) with MapProxy, straight from the
GeoPackage deliveries in EPSG:3006. Tiles are served byte for byte as delivered; nothing is
reprojected. A nightly timer (`mapproxy-refresh`) installs new deliveries from Lantmäteriet's FTP
server.

Played by `vm-fsicos4-mapproxy.yml`; Caddy on fsicos4 proxies `tiles.*` to the VM.

## Layout

```
/docker/mapproxy/            docker-compose.yml, refresh.py, refresh.json, justfile
/docker/mapproxy/config/     mapproxy.yaml, owned by the mapproxy user
/data/mapproxy/<layer.dir>/
    <generation>/<file>.gpkg        generation = gpkg_contents.last_change
    <generation>/<file>.gpkg.part   download in progress
    current.gpkg -> <generation>/<file>.gpkg
    seen.json                       remote MDTM/SIZE last dealt with
```

`/data/mapproxy` is mounted read-only in the container. At most two generations are kept per layer:
the installed one and the new one.

## Refresh

Each night, for each layer in turn:

1. If the remote MDTM and SIZE match `seen.json`, stop.
2. Read `last_change` from the first 256 KiB of the remote file. If it matches the installed
   generation, it's a republication: record it and stop.
3. Otherwise, remove older generations, download with `wget -c` (resuming a `.part` if one exists), validate the
   file against the grid, point `current.gpkg` at it, and restart MapProxy.

Downloads are limited to `mapproxy_refresh_rate_limit_mb` (50 MB/s), about an hour per layer.
Unthrottled, the VM pulls ~110 MB/s.

A rejected delivery is recorded in `seen.json` and is not downloaded again until Lantmäteriet
publishes a different file.

## Operations

`ops-mapproxy` on the VM: `status`, `logs`, `refresh`, `rollback <layer dir> <generation>`,
`verify`.

**Cold start:** after the first deploy there is nothing to serve. The first run (the 02:00 timer, or
`ops-mapproxy refresh`) installs both layers, one after the other, in about two hours. MapProxy
won't start while any layer's `current.gpkg` is missing, so it starts after the last layer is
installed. Then run the playbook again, so its tile check runs.

## Gotchas

- Don't run `mapproxy-seed`: the caches have no source, and seeding would write to the data.
- WMTS REST URLs are `…/{TileMatrix}/{TileCol}/{TileRow}.png` (column first); Lantmäteriet's own
  service uses row first.
- WMS 1.1.1 needs `STYLES=` (it can be empty), otherwise it returns a 500.
