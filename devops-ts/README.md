# devops-ts — a typed proof of concept

A small experiment in expressing the Ansible top-level playbooks (`../devops/*.yml`)
as TypeScript that **renders to semantically identical YAML** while being
**statically type-checked** — with very little boilerplate.

This sits alongside the existing `../devops-dhall` experiment as an alternative
take on the same idea.

## What's here

```
lib/ansible.ts      core types (Play, Task, RoleRef), the role() builder, render()
lib/roles.ts        per-role parameter schemas — the type-safety surface
playbooks/*.ts      converted playbooks (one per original .yml)
render.ts           render a playbook to YAML on stdout
verify.sh           prove every playbook matches its original .yml
deno.json           `deno task check | verify | render`
```

Seven playbooks are converted, chosen to cover the full structural range:

| Playbook       | Exercises                                                      |
| -------------- | ------------------------------------------------------------- |
| `matomo`       | bare role, no params                                          |
| `geoip`        | bare role + leading comments                                  |
| `keycloak`     | role with one required param                                  |
| `nexus`        | multiple roles, tags, templated (`{{ }}`) string params       |
| `mail-postfix` | list params, nested-record params, a custom-module task       |
| `cpauth`       | tagged roles, a `tasks:` section with `import_role`           |
| `core`         | multiple plays, `vars`, `pre_tasks`, list-valued tags, `when` |

## Usage

```bash
deno task check                      # type-check everything
deno task verify                     # render each playbook + diff vs ../devops/*.yml
deno task render playbooks/core.ts   # print the YAML for one playbook
```

`verify.sh` renders each `.ts` and compares it to the original `.yml` by parsing
**both** sides and deep-comparing the data structures. Ansible is insensitive to
key order and to scalar style (`yes` vs `true`, folded vs plain strings), so
semantic equality — not byte equality — is the correct bar, and all seven pass.

## How the typing works

Plays and tasks are **plain object literals** validated with `satisfies Playbook`.
No wrapper functions, no ceremony — you write the data and TypeScript checks the
shape, catching unknown keys and wrong value types:

```ts
export default [
  {
    hosts: "fsicos2",
    roles: [role("icos.keycloak", { kc_hostname: "keycloak.icos-cp.eu" })],
  },
] satisfies Playbook;
```

Roles go through one tiny builder, `role(name, vars?)`, because that is what lets
each role's parameters be typed by its name. `lib/roles.ts` maps every role to
its variable schema; the builder makes `vars` **required** when the role has
required variables and **optional** when it doesn't. Ansible role-keyword options
(tags, when) are attached separately with a chainable `.opt()`, keeping role
*variables* and Ansible *keywords* visually distinct:

```ts
role("icos.matomo")                                   // ok — no params
role("icos.keycloak", { kc_hostname: "..." })         // ok
role("icos.nexus").opt({ tags: "nexus" })             // tags/when via .opt()
role("icos.keycloak")                                 // error: vars required
role("icos.keycloak", { kc_hostnam: "..." })          // error: did you mean kc_hostname?
role("icos.kraken")                                   // error: unknown role
role("icos.dovecot", { dovecot_domains: "x" })        // error: expected string[]
```

All five mistake classes above are caught at `deno check` time, with TypeScript's
"Did you mean …?" suggestions.

## Why this is interesting next to the Dhall experiment

The Dhall conversion derives one enormous auto-generated `Task` type covering
every field seen across all roles, but **role parameters stay untyped** — a role
reference is `{ role : Text }` plus arbitrary fields, and polymorphic fields
become awkward union constructors (`Task.Poly_import_role.Record { … }`).

This TypeScript version instead:

- types **role parameters per role** (the most error-prone surface in practice —
  a misspelled `kc_hostname` silently does nothing in Ansible today);
- expresses "string or list of strings" as the native union `string | string[]`,
  no constructor tags at call sites;
- keeps playbooks reading almost exactly like the YAML, with comments preserved.

## Incremental adoption

This is designed to grow file-by-file:

1. Convert one `.yml` to a `.ts` playbook.
2. For any role it uses that isn't in `lib/roles.ts` yet, add its parameter
   schema (a few lines). Bare roles are just `{}`.
3. For any task module not yet in the `Task` interface, add an optional field.
4. `deno task verify` proves the output is unchanged.

Originals stay the source of truth until a playbook is converted and verified, so
the two can coexist exactly as the Dhall experiment does.

## Requirements

- [deno](https://deno.com/) (runs the `.ts` directly; pulls `npm:yaml` on first run)
- `python3` + `pyyaml` (used only by `verify.sh` for semantic comparison)
