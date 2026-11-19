# Plan: cpmeta graceful restart and periodic reindex (infra side)

Status: draft, 2026-10-15; updated 2026-10-26 after the fsicos2 crash analysis. Companion plan in the `meta` repo:
`docs/plans/graceful-shutdown-and-readonly-split.md`.

## Context

PR 72 adds a weekly `systemctl restart cpmeta.service` timer. Review findings:

- It bypasses `roles/icos.cpmeta/tasks/restart.yml`: no readonly switch before the
  restart, no `/buildInfo` health check after, and no readonly switch back on the
  failover instance (`cpmeta_readonly_mode: true`), which would come back writable
  every Sunday.
- It is installed unconditionally on every host using the role, with no way to disable
  or remove it.
- The unit name is hardcoded (`cpmeta.service` instead of `cpmeta_servicename`) and
  `ExecStart=systemctl` is not an absolute path.
- It will trigger false incidents in the new `cpmeta-diagnostics` probe and reset the
  JVM state the diagnostics are trying to capture.

## Key facts (from the meta source)

- `POST /admin/switchToReadonlyMode` blocks new write connections and dumps the SPARQL
  magic index to `/home/cpmeta/sparqlMagicIndex.bin`, plus the citation and DOI caches.
- At startup cpmeta restores the index from that file, then deletes it. If the file is
  missing or unreadable, it rebuilds the index from the triple store.
- The HTTP server binds only after the index is ready, so cpmeta is down during a rebuild.
- `-D` system properties do not override `application.conf` (cpauth `ConfigLoader`), so
  `recreateCpIndexAtStartup` cannot be set for a single restart.
- Existing risk: a jar deploy (`deploy.yml`) dumps with the old version and restores
  with the new one. The dump has no version stamp.

## Work

### 1. Measure first

- [ ] Time a full index rebuild on staging (delete the dump, restart, time until
      `/buildInfo` answers). This sets the poll budget and `TimeoutStartSec`, and decides
      whether dumping is worth it at all.

### 2. Rework PR 72 into a reindex restart

- [ ] Gate it behind `cpmeta_reindex_restart_enable` (default `false`) and set
      `timer_state` to `absent` when disabled, so turning it off removes it.
- [ ] Replace the raw `systemctl restart` with a script template
      (`cpmeta-reindex-restart`):
      1. `POST /admin/switchToReadonlyMode` (with `--max-time`, failure tolerated)
      2. `systemctl stop {{ cpmeta_servicename }}.service`
      3. `rm -f /home/{{ cpmeta_user }}/sparqlMagicIndex.bin`
      4. `systemctl start {{ cpmeta_servicename }}.service`
      5. Poll `/buildInfo` within the measured rebuild budget, exit non-zero on timeout
      6. If `cpmeta_readonly_mode`: switch back to readonly
- [ ] Service unit: `Type=oneshot`, `TimeoutStartSec` > rebuild time, absolute paths,
      and make sure a failed run alerts someone.
- [ ] Pause diagnostics during the window (maintenance marker checked by
      `diagnostics.py`, or stop `cpmeta-diagnostics.timer` around the restart).
- [ ] Do not schedule it to overlap the hourly borg backup.

### 3. After the meta changes are deployed

- [ ] Switch the script to the split endpoints:
      `POST /admin/readonly` → `POST /admin/dumpCaches` → stop → rm dump → start → poll.
      The index dump is no longer done just to be deleted.
- [ ] `templates/cpmeta.service`: add `SuccessExitStatus=143` and a `TimeoutStopSec`
      sized from the shutdown deadlines in the meta plan (section 1c: HTTP drain +
      SPARQL stop + store connection gate + metaflow, plus margin), not an index dump.
      The earlier 30–60 s guess is shorter than the 30 s drain plus the store wait.

### 4. Crash and memory diagnostics (from the 2026-10-26 fsicos2 incident)

Context: all 18 cpmeta crash reports on fsicos2 since January 2025 are SIGSEGV in
`liblwjgl_lmdb.so` during SIGTERM shutdown (store closed under active readers; fixed on
the meta side). On 2026-10-26 the JVM was also in back-to-back full GCs with the heap
~20% used, and no GC logs existed to explain why.

- [ ] `templates/cpmeta.service`: `LimitCORE=0` (or `-XX:-CreateCoredumpOnCrash`).
      The crash wrote a core dump of a 14+ GB heap, which kept the stop hanging until
      the 90 s SIGKILL. The hs_err file is enough.
- [ ] Deploy GC logging on production. `templates/diagnostics-gc.conf.j2` exists, but
      fsicos2 has no `cpmeta.service.d/` and cpmeta ran as plain `java -jar cpmeta.jar`.
- [ ] Set an explicit `-Xmx` instead of the ergonomic 1/8 of RAM (~30 GB on fsicos2).
- [ ] Keep enough journal history to cover a crash and its lead-up (on 2026-10-26 the
      journal only went back to 07:18 the same day).
- [ ] Track memory pressure separately: the 2026-07-26 crash followed heap exhaustion
      (31/31 GB, 857 full GCs after 29 days), and full GCs per run have risen through
      2026 (0 in every 2025 crash report, 103 in 8 days by 2026-10-14).
- [ ] `restart.yml`: keep calling the combined readonly + dump endpoint before planned
      restarts (or readonly + dumpIndex + dumpCaches). Keep the post-restart readonly
      switch for the failover instance.

## Decisions

- Graceful shutdown (drain, stop ingestion, close DB): yes. If the store still has
  active readers at the deadline, cpmeta exits without closing LMDB rather than
  crashing; the unit's stop timeout must leave room for that deadline.
- Dump the index on every shutdown by default: no, for now. It persists any
  index/store drift across restarts, restores dumps from an older jar version, and makes
  emergency restarts of a stalled JVM slow. Revisit if the rebuild time is large, and
  only once dumps carry a version stamp.
- Keep dumping explicit (readonly endpoint) for planned restarts.
