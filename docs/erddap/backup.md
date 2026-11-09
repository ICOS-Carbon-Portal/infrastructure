# ERDDAP backups

Encrypted Borg backups run inside `erddap-next` daily at 02:30 Europe/Stockholm
(plus up to five minutes' jitter).

- Repository: `icos1:/pool/bbserver/repos/erddap-essential.repo`.
- Retention: 14 daily, 8 weekly, 12 monthly archives.
- Includes: consistent SQLite snapshot, ICOS credentials, configuration,
  custom images, subscriptions, scripts and crontab.
- Excludes: CSVs, generated `datasets.xml`, runtimes, caches and logs.
  Rebuilding these depends on ICOS and artifact availability.

## Deploy and check

From `devops`: `icos play erddap --tags backup`.
Deployment runs a backup, including retention pruning.

Inside `erddap-next`, as root:

```bash
systemctl list-timers erddap-essential-backup.timer
journalctl -u erddap-essential-backup.service
/usr/local/sbin/erddap-borg list --short
# Run a backup manually:
systemctl start erddap-essential-backup.service
```

There is no external failure alerting. Check the journal for failures.

## Verify a restore

Run periodically and after backup changes; daily backups do not run this test.
Extract only into a temporary directory, never over live state:

```bash
/usr/local/sbin/erddap-borg check --verify-data --glob-archives 'essential-*' --last 1
umask 077
restore=$(mktemp -d /var/lib/erddap-backup/restore.XXXXXXXX)
archive=$(/usr/local/sbin/erddap-borg list --glob-archives 'essential-*' --last 1 --short)
(cd "$restore" && /usr/local/sbin/erddap-borg extract "::$archive")
sqlite3 -readonly "$restore/rootfs/home/ubuntu/erddap.icos-cp.eu/icos-erddap/erddap_transfer/erddap_transfer.sqlite" 'PRAGMA integrity_check;'
# Remove restored plaintext secrets after inspection:
rm -rf -- "$restore"
```

## Recovery essentials

Preserve the existing `vault_erddap_backup_passphrase`, access to Ansible Vault,
and the exported key at
`~/.config/icos/erddap-backup-repokey-<repository-id>.txt` on the controller.
Keep recovery credentials protected separately from the container.

After container loss, restore backup access and authorize its SSH key on `icos1`.
Files in archives are under `rootfs/`. Stop ingestion, backups and ERDDAP before
replacing live state; restore selected files and set database ownership to
`ubuntu:ubuntu`. Do not blindly restore the archived crontab.

A full extraction and SQLite integrity check passed on 2026-10-02, including
all 404 database records. See [the clean rebuild test](recovery-test.md)
for recovery without downloaded datasets.
