# icos.mapproxy

Serves Lantmäteriet's *Topografisk webbkarta* (colour and grey) with MapProxy, straight from their
GeoPackage deliveries in EPSG:3006 (grid `lm_3006`) and Web Mercator (grid `webmercator`). Tiles
are served byte for byte as delivered; nothing is reprojected. A nightly timer (`mapproxy-refresh`)
installs new deliveries from Lantmäteriet's FTP server.

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

There is a layer directory per delivery: `topowebb_color` and `topowebb_gray` for EPSG:3006, and
`topowebb_color_mercator` and `topowebb_gray_mercator` for Web Mercator. In WMTS and TMS, each
layer (`topowebb`, `topowebb_nedtonad`) is offered on both grids, as
`/wmts/<layer>/<grid>/{TileMatrix}/{TileCol}/{TileRow}.png`. WMS is EPSG:3006 only.

`/data/mapproxy` is mounted read-only in the container. At most two generations are kept per layer:
the installed one and the new one.

## Refresh

Each night, for each layer in turn:

1. If the remote MDTM and SIZE match `seen.json`, stop.
2. Read `last_change` from the first 256 KiB of the remote file. If it matches the installed
   generation, it's a republication: record it and stop.
3. Otherwise, remove older generations, download with `wget -c` (resuming a `.part` if one exists), validate the
   file against the layer's grid, point `current.gpkg` at it, and restart MapProxy. After a layer's
   first delivery, MapProxy isn't restarted: the playbook has to run again to serve it.

Downloads are limited to `mapproxy_refresh_rate_limit_mb` (10 MB/s), about four hours per layer.
Unthrottled, the VM pulls ~110 MB/s.

A rejected delivery is recorded in `seen.json` and is not downloaded again until Lantmäteriet
publishes a different file.

## Operations

`ops-mapproxy` on the VM: `status`, `logs`, `refresh`, `rollback <layer dir> <generation>`,
`verify`.

**New layers and cold start:** MapProxy fails, for every layer, while any GeoPackage in its config
is missing. So until every layer's `current.gpkg` exists, the playbook leaves `mapproxy.yaml` as it
is (on a cold start it doesn't start MapProxy at all). Run `ops-mapproxy refresh` (or wait for the
02:00 timer), which downloads the missing layers one after the other, about four hours each. Then run
the playbook again: it writes the new config and restarts MapProxy.

## Gotchas

- While any layer's GeoPackage is missing, the playbook doesn't touch `mapproxy.yaml`, so none of
  its changes are deployed, not only the new layer. After adding a layer: run the playbook, run
  `ops-mapproxy refresh`, then run the playbook again. If a delivery is rejected, the config
  stays held back until Lantmäteriet publishes a good one.
- Don't start the container by hand before `mapproxy.yaml` exists: the image then writes an
  example config of its own and serves that.
- Don't run `mapproxy-seed`: the caches have no source, and seeding would write to the data.
- WMTS REST URLs are `…/{TileMatrix}/{TileCol}/{TileRow}.png` (column first); Lantmäteriet's own
  service uses row first.
- WMS 1.1.1 needs `STYLES=` (it can be empty), otherwise it returns a 500.
