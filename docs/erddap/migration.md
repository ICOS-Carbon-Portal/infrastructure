# ERDDAP migration record

Production moved to `erddap-next` on fsicos2 on **2026-10-07**, following upgrades
to Ubuntu 24.04, Tomcat 10.1.60, ERDDAP 2.31.1 and Java 25.

At cutover, all 391 source files matched by SHA-256, all 783 catalog IDs matched,
and sample table/grid queries passed. No datasets failed to load. A post-cutover
off-host backup succeeded. These checks were not exhaustive query validation.

The old `erddap` container was stopped with `boot.autostart=false`; its storage
was retained. Saved configuration:

- fsicos2: `/root/erddap-cutover-20261007/erddap.conf`
- Old `erddap`: `/root/erddap-cutover-20261007/ubuntu.crontab`

Before rollback, pause new ingestion and reconcile subsequent state changes.
Review saved configuration before restoring it; validate nginx before reloading.
Resume old ingestion only when safe. The pre-upgrade snapshot from September
predates production state and is not a current recovery point.

See [current operations](README.md) and [backups](backup.md).
