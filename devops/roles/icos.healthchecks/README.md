# icos.healthchecks

Runs [Healthchecks](https://github.com/healthchecks/healthchecks) with Postgres in Docker. Timers
made with `icos.timer` report to it when they set `timer_healthcheck: true`.

## After the first deploy

1. Log in as `healthchecks_admin_email`. The superuser is only created on the first run; changing
   the variables later doesn't change the account.
2. In the project's settings, create a read-write API key and a ping key, and add them to
   `group_vars/all/vault.yml` as `vault_healthchecks_api_key` and `vault_healthchecks_ping_key`.
3. Set up integrations (email, chat, ...) in the UI. Checks registered by `icos.timer` alert
   through all of them.
4. Run the playbooks of the timers that set `timer_healthcheck: true`.

Backups are not enabled; `tasks/backup.yml` can be modified to enable them.
