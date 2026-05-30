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

### Phase 3 — variables / handlers (large; opt-in per role) — **started**
Measured scope of variable references across role tasks (599 distinct):
- 51% a role's own `defaults/` — statically enumerable, the typed target.
- 24% caller params / `set_fact` / loop `item` — dynamic, not enumerable.
- 11% registered results (`_x`) — dynamic.
- 5% globals/inventory, 5% other-role defaults, 4% builtins, 1% vault.

So ~66% is statically knowable; ~34% is irreducibly dynamic. Design:
- `lib/context.ts`: a generic `context<Vars>()` factory → `{ V, tmpl, isDef,
  notVar }` scoped to one role's variable interface (same machinery as the
  global `V`/`tmpl`, but per-role).
- `gen-contexts.ts` (`deno task gen-contexts`): reads each role's
  `../devops/roles/<role>/{defaults,vars}/*.yml`, infers types, and writes
  `roles/<role>/_ctx.ts` with a `Vars` interface + `context<Vars>()`. **All 104
  generated and type-checking.**
- A role task file opts in per-reference:
    `import { V, tmpl, isDef } from "../_ctx.ts";`
  Convert references the context knows (own-defaults); leave dynamic ones as raw
  `"{{ }}"` strings / `raw()`. Proven on `icos.cpauth` (setup.ts, deploy.ts):
  renders identically, type-checks, and a typo (`V.cpauth_hom`) is a compile
  error with a "Did you mean" hint.

**Phase 3 rollout: done.**
- Contexts widened: `lib/globals.ts` (143 group_vars/inventory vars) + an
  expanded `lib/builtins.ts` are intersected into every role context
  (`Vars & Globals & Builtins`), so globals/builtins references are checked too,
  not just own-defaults. The generator excludes a role's own var when a
  global/builtin already declares it (avoids a `boolean & string -> never`
  intersection clash).
- `codemod-contexts.ts` rewrote the role files mechanically (far more reliable
  than agents for pure find/replace), with `verify.ts` as the oracle:
    `"{{ var }}"`            -> `V.var`
    `"{{ var }}/suffix"`     -> `tmpl`${V.var}/suffix``
    `raw("var is defined")`  -> `isDef("var")`
  It masks backtick template literals (never touches multi-line blocks), only
  converts the exact `{{ var }}` spacing the renderer emits (byte-identical
  round-trip), and leaves every out-of-context (dynamic) reference untouched.
- Result: **237 role files** now use the typed context; **813 `V.` refs + 307
  `tmpl` composites** typed; 118 genuinely-dynamic refs remain raw by design.
  `deno task check` clean, `deno task verify` **464/464**. A typo in a known var
  (`V.rdflog_hom`) is a compile error with a "Did you mean" hint.

### Phase 3b — typed loops — **done**
Loops were the densest "dynamic" tier. Measured 109 looped tasks: 52% inline
scalar list, 20% inline list-of-dicts, 23% `loop: "{{ var }}"`, 5% filtered
expression. The inline forms (72%) carry the element type in the array literal —
the only thing missing was *binding* it to the `item` references (which were
opaque `"{{ item.src }}"` strings).

- `lib/loop.ts`: `loopOver(items, item => body)` (and `withItemsOver` for the
  legacy `with_items:` key). `item` is a proxy typed `Item<T>` — element keys
  exposed as refs (`item.src` -> "{{ item.src }}", `item.scr` is a compile
  error), and a bare `item` for scalar loops.
- Rolled out to **all 22 inline-list-of-dicts loop tasks** (18 files) — the
  high-value set where `item.X` typo-checking bites. Scalar-list loops were left
  as-is (a string `item` has no attributes to mistype, so no benefit).
  `deno task check` clean, `deno task verify` 464/464.

What's still dynamic in loops (by design): filtered item refs
(`item.dest | default(...)`, 13% of item refs) stay raw; and `loop: "{{ var }}"`
where the var's element type isn't known.

Optional future work:
- Carry element types for list-valued context vars so `loopOver(V.x, …)` types
  `item` from the var (would recover much of the 23% `loop: "{{ var }}"` tier).
- A value-position filter DSL (`item.dest.default(V.x)`) for the 13% filtered refs.
- Typed `register` handles (`_r.stdout`) and `set_fact` outputs — the other
  dynamic tiers, same binding idea applied to results.
- Typed handler names so `notify` is checked; per-role vault var sets.

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
- **Phase 3 (per-role variable contexts): done.** Machinery
  (`lib/context.ts`, `lib/globals.ts`, `gen-contexts.ts`, `codemod-contexts.ts`),
  104 contexts generated, and the bulk per-reference rollout applied across 237
  role files — 813 `V.` refs + 307 `tmpl` composites typed, dynamic refs left
  raw. `deno task check` clean, `deno task verify` 464/464.
