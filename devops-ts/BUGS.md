# Latent bugs found during the TypeScript conversion

Bugs in the original `../devops` YAML that the typed conversion surfaced. Fixing
one means changing **both** trees in lockstep (the `deno task verify` gate
requires byte-identical rendering), then re-running `deno task verify`.

## Resolved

### icos.nextcloud — broken config-backup dance in `tasks/nginx.yml` (FIXED)

The `Copy nextcloud-nginx.conf` template took no backup, the `rescue:` restore
referenced an undefined `update.backup_file` with no guard, and the `always:`
"Remove backup file" task referenced `_r.backup_file` / `_r['backup_file'] is
defined` — but the file registers `update`, never `_r`, so the cleanup was dead
code. Fixed (mirroring `icos.nebula/tasks/config.yml`) in both
`../devops/roles/icos.nextcloud/tasks/nginx.yml` and
`roles/icos.nextcloud/tasks/nginx.ts`:

- added `backup: true` to the `template:` task;
- guarded the `rescue:` restore with `when: "update['backup_file'] is defined"`;
- pointed the `always:` task at `update` (TS: `update.backup_file.ref` /
  `raw("update['backup_file'] is defined")`).

### icos.zrepl — same phantom-`_r` register in `tasks/config.yml` (FIXED)

The `always:` "Remove backup file" task referenced `_r.backup_file`, but the
file registers `update` (and already sets `backup: true`, so only the
wrong-register-name bug applied). Fixed in both
`../devops/roles/icos.zrepl/tasks/config.yml` and
`roles/icos.zrepl/tasks/config.ts` by pointing it at `update`.

In TS both sites now use the typed `update` handle instead of `expr()`/`raw()`
strings, so an unregistered name is a compile error — the class of bug can no
longer be reintroduced silently.
