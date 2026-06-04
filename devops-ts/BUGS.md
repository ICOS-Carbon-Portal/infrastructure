# Latent bugs found during the TypeScript conversion

Bugs in the original `../devops` YAML that the typed conversion surfaced. The TS
port reproduces them faithfully (the `deno task verify` gate requires
byte-identical rendering), so fixing one means changing **both** trees — or
fixing `../devops` first and re-running the converters.

## icos.nextcloud: broken config-backup dance in `tasks/nginx.yml`

**Files:** `roles/icos.nextcloud/tasks/nginx.ts` (TS),
`../devops/roles/icos.nextcloud/tasks/nginx.yml` (origin).

The role uses the validate-with-rescue pattern shared by `icos.nebula`
(`tasks/config.yml`, register named `update`) and `icos.caddy`
(`tasks/config.yml`, register named `_r`). The nextcloud copy mixes the two and
breaks twice:

1. **The template task takes no backup.** Unlike nebula/caddy, the
   `Copy nextcloud-nginx.conf` task has no `backup: true`, so
   `update.backup_file` is never set. If `nginx -t` validation ever fails, the
   `rescue:` task "Restore config file" references the undefined
   `{{ update.backup_file }}` and the rescue itself errors out — the broken
   config is left in place (note it also lacks the
   `when: "update['backup_file'] is defined"` guard that nebula has).

2. **The `always:` block references the wrong register.** "Remove backup file"
   uses `{{ _r.backup_file }}` / `when: "_r['backup_file'] is defined"` —
   caddy's register name — but this file registers `update`, and `_r` is never
   registered anywhere in the role. The `when:` is therefore always false and
   the task is dead code. (This also masks bug 1: had it referenced `update`,
   the missing `backup: true` would still make it a no-op.)

Net effect: the "validate, restore on failure, clean up backup" machinery is
inert — validation failure dumps the numbered config (that part works) but
cannot restore the previous config, and no backup is ever created or removed.

**Suggested fix** (mirroring `icos.nebula/tasks/config.yml`):

- add `backup: true` to the `template:` task;
- in `rescue:` guard the restore with
  `when: "update['backup_file'] is defined"`;
- in `always:`, replace both `_r` references with `update` (in TS:
  `update.backup_file.ref` / `raw("update['backup_file'] is defined")`).

Apply to `../devops/roles/icos.nextcloud/tasks/nginx.yml` and mirror in
`roles/icos.nextcloud/tasks/nginx.ts` (or temporarily exempt the file from
`verify.ts` if the trees must diverge).

## icos.zrepl: same phantom-`_r` register in `tasks/config.yml`

**Files:** `roles/icos.zrepl/tasks/config.ts` (TS),
`../devops/roles/icos.zrepl/tasks/config.yml` (origin).

Found while sweeping the remaining `expr()` escapes (the `_r` reference can only
be written as a string — a typed `register()` handle for an unregistered name is
a compile error, which is how this surfaced). The `always:` "Remove backup file"
task uses `{{ _r.backup_file }}` / `when: "_r['backup_file'] is defined"`, but
the file registers **`update`** (and `_r` is never registered), so the `when:`
is always false and the cleanup is dead code — exactly bug 2 above.

Unlike nextcloud, the `copy:` task here **does** set `backup: true`, so bug 1
does not apply: had the `always:` block referenced `update`, it would work.

**Suggested fix:** replace both `_r` references with `update` (in TS:
`update.backup_file.ref` / `raw("update['backup_file'] is defined")`), applied
to `../devops/roles/icos.zrepl/tasks/config.yml` and mirrored in the TS.

Both `_r` sites are deliberately left as `expr()`/`raw()` escapes (not converted
to the typed `update` handle) so the TS tree stays byte-identical to `../devops`
until the bug is fixed in both trees.
