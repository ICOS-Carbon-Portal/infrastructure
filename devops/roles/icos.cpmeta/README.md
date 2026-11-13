# cpmeta stall diagnostics

## Purpose and deployment

Uptime Kuma records availability; Nginx logs in OpenSearch establish request
latencies, failures and traffic. These diagnostics add JVM evidence to explain
stalls. They do not install another monitoring stack or send alerts: continue
using Kuma for notifications.

From `devops/`, using the usual vault credentials:

```sh
ansible-playbook -i production.inventory cpmeta-diagnostics.yml --limit fsicos2 --check --diff
ansible-playbook -i production.inventory cpmeta-diagnostics.yml --limit fsicos2
```

**Use this dedicated playbook, not `cpmeta.yml`: the normal role includes a
restart step.** This playbook reloads systemd definitions, starts diagnostic
and sysstat timers, and uses `jcmd VM.log` on the running JVM. It never restarts
cpmeta or Nginx. A service drop-in persists JVM logging for future starts by
setting `JDK_JAVA_OPTIONS` (read by the `java` launcher only, not by `jcmd`); it
does not touch `ExecStart`, which stays as defined by the cpmeta role. cpmeta
then logs one `NOTE: Picked up JDK_JAVA_OPTIONS` line at startup.

Requirements: a running Java 9+ cpmeta JVM, matching JDK `jcmd`, systemd, and
Debian/Ubuntu's `sysstat-collect.timer`. The playbook installs curl, Python and
sysstat, but deliberately does not replace Java. Check mode cannot fully test
runtime JVM commands. Review host changes before applying: sysstat sampling is
changed for the entire host, not just cpmeta.

## Probe and capture behavior

- Direct localhost HTTP probe every 15 seconds, bypassing Nginx and proxy env.
- Correct Host header, HTTP 200 required, three-second connect and five-second
  total timeout. No redirects are followed. This is a status check, not content
  validation; choose a stable, cheap object URL that exercises metadata reads.
- Default object URL was verified with HTTP 200 on fsicos2. Override
  `cpmeta_diagnostics_probe_url` and `cpmeta_diagnostics_probe_host` per instance.
- Each result is one of:
  - `healthy`: HTTP 200.
  - `stalled`: timeout, broken response or a status other than 200/404/410
    from a listening cpmeta. Only this counts towards a capture.
  - `down`: connection refused (cpmeta stopped, restarting, or rebuilding its
    index before it binds). Resets the failure count.
  - `missing`: 404/410, i.e. the probe object is gone. Resets the failure
    count; fix `cpmeta_diagnostics_probe_url`.
- After three consecutive `stalled` results: three JVM thread dumps five
  seconds apart, listening queues, process summary, memory/CPU/I/O samples and
  recent journal.
- No capture while the JVM is younger than `cpmeta_diagnostics_min_uptime`
  (ten minutes), so deploys and restarts don't trigger one.
- Ten-minute cooldown, ten-second timeout per diagnostic command, 150-second
  service deadline. Systemd prevents overlapping invocations; probes pause while
  a capture runs. No automatic restart, heap dump or forced GC.
- Persistent state avoids repeated capture if the timer restarts.
- Probe results and recovery events go to journald (system journal retention).
- Incident directories are root-only and deleted after seven days on subsequent
  probe runs. Configure `cpmeta_diagnostics_retention_days` to change this.
- `/var/log/cpmeta-diagnostics` (state, incidents) belongs to root, mode 0711.
  The JVM writes GC/safepoint logs to its own `gc/` subdirectory (cpmeta, 0700):
  five rotated 20 MB files plus the active file. cpmeta cannot write next to
  the files root manages. Thread dumps/journals can contain sensitive
  application details; do not publish them without review.
- Sysstat collects each minute instead of every ten minutes. Its existing
  retention policy remains unchanged; allow for increased disk usage.

## Verify and investigate

```sh
systemctl status cpmeta-diagnostics.timer sysstat-collect.timer
systemctl list-timers cpmeta-diagnostics.timer sysstat-collect.timer
journalctl -u cpmeta-diagnostics.service --since '10 minutes ago' --utc
sudo ls -lh /var/log/cpmeta-diagnostics/ /var/log/cpmeta-diagnostics/gc/
sudo -u cpmeta jcmd "$(systemctl show cpmeta -p MainPID --value)" VM.log list
```

Check GC logging is listed and the probe returns HTTP 200 before relying on
capture. Compare cpmeta MainPID/start time before and after deployment to verify
no application restart. For an incident:

1. Use Kuma to locate the UTC interval.
2. In OpenSearch, inspect Nginx upstream timings, 429/499/502/503/504 counts,
   cache status, clients and paths. Fast proxy rejections distort overall latency;
   missing upstream timings are not zero-duration backend responses.
3. Compare `gc/gc.log*` pauses with `incident-<UTC>/threads-*.txt`. Look for repeated
   blocked stacks, dispatcher threads doing blocking I/O, and JVM pauses.
4. Use sysstat history to separate JVM trouble from host CPU, swap or disk pressure.
5. Journal and GC wall-clock timestamps may carry different timezones; normalize
   them to UTC. A long gap alone does not prove a GC pause.

Thread dumps have some overhead; the threshold, bounded commands and cooldown
limit it. A fully unresponsive JVM may not answer jcmd; timeout files preserve
that fact. An external Kuma check remains necessary if the host itself fails.

## Rollback (no cpmeta restart)

Stop/disable `cpmeta-diagnostics.timer`. Remove its service/timer and
`/etc/systemd/system/cpmeta.service.d/diagnostics.conf`, then daemon-reload.
To disable only the dynamically added GC file output (not all JVM logging):

```sh
sudo -u cpmeta jcmd "$(systemctl show cpmeta -p MainPID --value)" VM.log \
  output=/var/log/cpmeta-diagnostics/gc/gc.log what=all=off
```

Remove `/etc/systemd/system/sysstat-collect.timer.d/diagnostics.conf`, reload
systemd and restart **only sysstat-collect.timer** to restore the vendor cadence.
Preserve incident files until investigation is complete. Remove the collector
script when no longer needed. Do not disable existing sysstat monitoring.

## Incident reference

See [2026-10-14 fsicos2 stall](../../docs/incidents/2026-10-14-cpmeta-stall.md).
