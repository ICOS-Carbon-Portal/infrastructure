# ERDDAP

Production runs in `erddap-next` on fsicos2 (`ssh -p 60581 root@fsicos2`).
Both `erddap.icos-cp.eu` and `test-erddap.icos-cp.eu` serve this instance.

## Deploy

From `devops`:

```bash
icos play erddap                          # application and backups
icos play erddap --tags backup            # backups only
icos play erddap --skip-tags backup       # application only
icos play vm-erddap                       # container, certificates and nginx
icos play vm-erddap --tags cert,nginx     # certificates and proxy only
```

## Configuration

In `devops/production.inventory/host_vars/erddap-next/`:

- `main.yml`: application settings.
- `vault.yml`: encrypted secrets, loaded automatically.

Edit secrets from `devops`:

```bash
ansible-vault edit production.inventory/host_vars/erddap-next/vault.yml
```

Required keys: `vault_erddap_email_username`, `vault_erddap_email_password`
(`""` if unused), `vault_erddap_flag_key` (nonempty), and
`vault_erddap_backup_passphrase` (preserve the existing value).
Never commit plaintext secrets or the Vault password.

Runtime pins are in `devops/roles/icos.erddap/defaults/main.yml`; update versions
and checksums together. Ingestion runs at 01:05 Europe/Stockholm, with the
checker disabled. [Backups](backup.md) run at 02:30.

## Check health

```bash
curl -fsS https://erddap.icos-cp.eu/erddap/version_string
```

Check `/erddap/status.html` and representative dataset downloads. Inside the
container, use `journalctl -u erddap`; scheduled ingestion logs to
`/home/ubuntu/erddap.icos-cp.eu/ingestion.log`.

## Rebuild

For an empty container, set `erddap_service_enabled`, `erddap_state_ready`, and
`erddap_ingestion_enabled` to `false`, and deploy with `--skip-tags backup`.
Ansible does not restore application data or ICOS credentials. Restore/rebuild
state first, enable and validate the service, then enable ingestion and backups.
See the [recovery test](recovery-test.md) for rebuild limitations.

The old `erddap` container is retired and no longer managed by Ansible; see the
[migration record](migration.md).
