# icos.timer

Creates a systemd timer and the oneshot service it starts. Variables and their defaults are in
`defaults/main.yml`.

```yaml
- include_role:
    name: icos.timer
  vars:
    timer_name: cleanup
    timer_home: /opt/cleanup
    timer_conf: |
      OnCalendar=*-*-* 04:00:00
    timer_content: |
      #!/bin/bash
      find /opt/cleanup/tmp -mtime +7 -delete
```

- `timer_content` needs a `timer_home` other than `/etc/systemd/system`; units outside it are
  added with `systemctl link`
- Removing (`tasks_from: remove`) stops and disables the timer, but leaves its files in place

## Reporting to Sentry Crons

With `timer_sentry_monitor: true`, runs are reported to Sentry Crons
(<https://sentry.icos-cp.eu>, `icos.sentry`), which creates an issue when a run fails, takes too
long or doesn't happen on schedule.

```yaml
- include_role:
    name: icos.timer
  vars:
    timer_name: mapproxy-refresh
    timer_conf: |
      OnCalendar=*-*-* 02:00:00
      Persistent=true
    timer_exec: /usr/bin/python3 /docker/mapproxy/refresh.py /docker/mapproxy/refresh.json
    timer_sentry_monitor: true
```

- Every playbook run creates or updates the monitor `<inventory_hostname>-<timer_name>`
  (override with `timer_sentry_monitor_slug`, at most 50 characters) from the Ansible controller,
  so the auth token is not deployed to remote servers
- The service sends an `in_progress` check-in when a run begins and `ok` or `error` when it ends.
  A failed run also sends an error event with the run's journal attached (check-ins can't carry
  output), grouped into one issue per timer and linked to the check-in by trace ID. A Sentry
  outage never makes the job fail
- The schedule is the `OnCalendar=` line of `timer_conf`, which must have exactly one, converted
  to a cron expression. Schedules without a cron equivalent (seconds, years, `~`, a day of month
  combined with a weekday) fail the play
- `timer_sentry_checkin_margin_minutes` is how late a run may start before it counts as missed
  (any `RandomizedDelaySec=` is added to it), and `timer_sentry_max_runtime_minutes` is how long
  it may run before it counts as failed
- Removing the timer with `timer_sentry_monitor: true` deletes the monitor
- Sentry only notifies about monitor issues through the project's alert rules, which are set up
  by hand in the UI
- Sentry is stopped every night during its backup (`icos.sentry`); check-ins sent then are lost
- `vault_sentry_timer_auth_token` and `vault_sentry_timer_public_key` are required when a timer
  has `timer_sentry_monitor` enabled
