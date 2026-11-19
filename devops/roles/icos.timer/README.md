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

## Reporting to healthchecks

With `timer_healthcheck: true`, runs are reported to <https://healthchecks.icos-cp.eu>
(`icos.healthchecks`), which alerts when a run fails or doesn't happen on schedule.

```yaml
- include_role:
    name: icos.timer
  vars:
    timer_name: mapproxy-refresh
    timer_conf: |
      OnCalendar=*-*-* 02:00:00
      Persistent=true
    timer_exec: /usr/bin/python3 /docker/mapproxy/refresh.py /docker/mapproxy/refresh.json
    timer_healthcheck: true
    # A refresh usually takes seconds, but up to 5 hours when there's a new map.
    timer_healthcheck_grace: 21600
```

- Every playbook run creates or updates the check `<inventory_hostname>-<timer_name>` (override
  the name with `timer_healthcheck_slug`), from the Ansible controller, so the API key is not
  deployed to remote servers
- The service pings `/start` when a run begins and success or `/fail` when it ends, with the
  run's journal output attached; a healthchecks outage never makes the job fail
- The schedule is the `OnCalendar=` line of `timer_conf`, which must have exactly one
- Removing the timer with `timer_healthcheck: true` deletes the check
- `vault_healthchecks_api_key` and `vault_healthchecks_ping_key` (in `group_vars/all/vault.yml`)
  are needed as soon as a timer opts in, including in check mode; they can only be created once
  healthchecks is deployed, see `roles/icos.healthchecks/README.md`
