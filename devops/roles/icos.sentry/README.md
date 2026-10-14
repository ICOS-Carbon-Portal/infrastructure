# icos.sentry

Installs and updates Sentry self-hosted and configures cold Borg backups through `icos.bbclient2`.

## Install/update

The role keeps `/opt/sentry-self-hosted` checked out at `sentry_version`. It runs Sentry's upstream `install.sh` only on first install, when the checkout changes, or when `sentry_run_install=true`. For an explicit upgrade, change `sentry_version` and run the playbook after taking a VM snapshot and a fresh backup.

```bash
icos play vm-fsicos4-sentry sentry
```

Set `sentry_run_install=true` to force the upstream installer to run without changing the tag.

## Backup

`tasks/backup.yml` installs a systemd timer using `icos.bbclient2`. The backup is intentionally cold:

1. Optionally runs a noninteractive logical export with telemetry disabled and `--minimize-downtime`. A failed export is removed and logged, but does not block the cold backup.
2. Discovers Sentry Docker volumes, aborting on discovery failure or an empty result.
3. Stops Sentry with `docker compose stop --timeout 120`, preserving containers and their volume attachments.
4. Borg-backs up `/opt/sentry-self-hosted` and the Docker volume mountpoints.
5. Starts Sentry and waits for health before pruning/compacting the repository. An exit trap also attempts recovery if stopping or backing up fails.

Check `systemctl status bbclient-sentry.service` and `/opt/bbclient-sentry/bin/bbclient-all list --short` after deployment. A restore rehearsal is still needed to validate disaster recovery.

The logical export is not considered sufficient for disaster recovery; Sentry self-hosted also stores state in ClickHouse, Kafka, Redis, SeaweedFS/blob storage and named Docker volumes.

## Restore

The backup task installs `/usr/local/sbin/sentry-borg-restore`. Run it manually with an archive name from `bbclient-all list --short`.

```bash
/opt/bbclient-sentry/bin/bbclient-all list --short
/usr/local/sbin/sentry-borg-restore ARCHIVE_NAME
```
