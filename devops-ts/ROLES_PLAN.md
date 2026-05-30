# Plan: typing `roles/*/tasks/*.yml`

Porting the role task files is the large frontier beyond the 67 top-level
playbooks. This document records the analysis and the phased plan.

## Scope (measured)

| Metric | Count |
| --- | --- |
| Roles with task/handler files | 104 |
| Task/handler `.yml` files | 399 |
| Task items (incl. nested in blocks) | 1,561 |
| Distinct module names | 85 (17 FQCN, e.g. `community.docker.*`) |
| Role variables in `defaults/` + `vars/` | ~632 across 139 files |
| `.j2` templates | 10 |

Module usage is long-tailed but concentrated: the top ~15 modules (`file`,
`copy`, `template`, `systemd`, `apt`, `command`, `shell`, `service`, `user`,
`set_fact`, `uri`, …) dominate; ~70 others appear a few times each.

## The core difference from playbooks

Playbooks are standalone (`Play[]`, one file). Role tasks are a **tree of
interdependent files**: 223 `import_tasks`/`include_tasks` references wire
sibling files together (`main.yml` → `setup.yml` → `install.yml` …), plus
`handlers/` and `defaults/`. A role is a directory, not a single document.

## What the static type system can and cannot check

Genuinely checkable: module argument shapes, role-variable *names*, handler
names, `import/include` targets, tags.

Fundamentally dynamic (not statically checkable): `register` results referenced
later (`r.rc`, `_conf.changed` — 260 registers), `loop` `item`/`item.x` (104
loops), `set_fact`-created variables (35), and free-form Jinja `when`
expressions (~100 of 173 single-line `when`s use `==`, `!=`, `in`, `| bool`,
`| default`, attribute access, `and`/`or`).

## Phases

### Phase 0 — plumbing (small, unblocks everything)
- `TaskFile = Task[]` type for a bare role task file.
- `render()` accepts a `TaskFile` (bare YAML sequence) as well as a `Playbook`.
- Directory mirror: `devops-ts/roles/<role>/tasks/<file>.ts`.
- `verify.ts` walks the `roles/` tree too and diffs each against
  `../devops/roles/<role>/tasks/<file>.yml`.

### Phase 1 — expressions (medium; revisits the no-escape-hatch decision)
- Keep the typed core (`isDefined`, `not`, `.default`).
- Add `raw(text)` → `Expr`: an explicit, greppable escape for the dynamic ~60%
  of `when`s (registered results, loop items, comparisons, filters). This is
  deliberately different from the removed *implicit* string→`When` coercion —
  it is auditable (`grep raw(`).
- Add a few safe combinators (`and`, `or`) that compose `Expr`s.
- `changed_when`/`failed_when` already accept `boolean | string | string[]`.

### Phase 2 — modules (medium) — **done**
- Precise schemas (supersets of real usage, derived by analysing every `.yml`)
  for ~25 modules: `file`, `copy`, `template`, `systemd`, `service`, `apt`,
  `command`, `shell`, `debug`, `set_fact`, `fail`, `user`, `uri`, `stat`,
  `get_url`, `unarchive`, `pip`, `blockinfile`, `lineinfile`, `cron`, `git`,
  `authorized_key`. The long tail keeps falling through `Task`'s index signature.
- `Flag = boolean | string` for templatable booleans; `Mode = string | number`;
  `Names = string | string[]`. Modules with a `name=value` shorthand (`shell`,
  `service`, `debug`, `pip`, `set_fact`) accept `string | {...}`.
- FQCN aliases share the type (`ansible.builtin.shell` ↔ `shell`, etc.).
- Caught in negative tests: missing required `copy.dest`, typo'd `template.dset`,
  wrong `fail.message` (vs `msg`).

### Phase 3 — variables / handlers (large; opt-in per role)
- Per-role variable contexts generated from `defaults/` + `vars/` (~632 vars),
  modelling scope (own role vars + globals + registered + `item` + set_fact).
- Typed handler names so `notify` is checked.

## Verification strategy
Same as playbooks: `verify.ts` renders each `.ts` and deep-compares (YAML 1.1)
to the original. Render-correctness for all 399 files is very achievable;
type-completeness is the cost. Parallelises with agents per role.

## Honest assessment
~6–8× the playbook effort, and the ROI of typing drops here: role tasks are
dense with values a static checker can't validate. Recommendation: do Phases
0–2 (plumbing + `raw()` escape + top-module typing) for most of the realistic
value; treat Phase 3 as opt-in. The checkable wins are module-arg shapes,
role-var names, handler names, and include targets.

## Status
- **Phase 0: done.** `TaskFile` type; `render()` accepts a task file; `verify.ts`
  walks `roles/<role>/{tasks,handlers}/*.ts` against the originals; `deno.json`
  `check`/`fmt` include the `roles/` tree.
- **Phase 1: done.** `raw(text)` explicit `when:` escape plus `and()`/`or()`
  combinators (in `lib/vars.ts`, re-exported from `lib/ansible.ts`). `import_tasks`
  / `include_tasks` typed on `Task`. A raw *string* `when:` is still rejected —
  `raw()` is the sole, greppable escape.
- **Validation role `icos.cpauth` (5 files): all render identically and
  type-check.** Exercised: `import_tasks` with `when`, `register`, `changed_when`
  / `failed_when`, `retries`/`delay`/`until` (via the `Task` index signature),
  literal-block `content`, object- and string-form `include_role`, task-level
  `vars`, a `daemon-reload` hyphenated module key.
- **Bulk role port: done.** All 104 roles ported — 397 task/handler `.ts` files
  (the 2 remaining source files are empty/comments-only and correctly skipped).
  Done with parallel agents using `verify.ts` as the oracle.
  - `deno task verify`: **464 / 464** (67 playbooks + 397 role files).
  - `deno task check`: clean.
  - Library changes the port required: `When = Expr | Expr[]` (YAML list-form
    `when:`); the `Tag` union regenerated to the full ~299 tags actually used;
    `file?: FileArgs | string` (key=value shorthand); `become?: boolean | string`
    (templated); `VarValue` now allows `null`.
- Phase 3 (per-role variable contexts) remains opt-in / future work.
