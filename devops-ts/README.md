# devops-ts — a typed proof of concept

A small experiment in expressing the Ansible top-level playbooks (`../devops/*.yml`)
as TypeScript that **renders to semantically identical YAML** while being
**statically type-checked** — with very little boilerplate.

This sits alongside the existing `../devops-dhall` experiment as an alternative
take on the same idea.

## What's here

```
lib/ansible.ts      core types (Play, Task, RoleRef), the role() builder, render()
lib/roles.ts        per-role parameter schemas — what each role accepts
lib/vars.ts         catalogue of available variables + V / tmpl / when-helpers
lib/builtins.ts     Ansible built-in vars / facts (e.g. ansible_check_mode)
lib/hosts.ts        closed union of valid `hosts:` targets (from the inventory)
playbooks/*.ts      converted playbooks (one per original .yml)
render.ts           render a playbook to YAML on stdout
verify.ts           prove every playbook matches its original .yml
deno.json           `deno task check | verify | render`
```

33 playbooks are converted. A representative subset, covering the full
structural range:

| Playbook         | Exercises                                                       |
| ---------------- | --------------------------------------------------------------- |
| `matomo`, `maps` | bare role, no params                                            |
| `geoip`          | bare role + leading comments                                    |
| `keycloak`       | role with one required param                                    |
| `nexus`          | multiple roles, tags, templated (`{{ }}`) string params         |
| `mail-postfix`   | list params, nested-record params, a custom-module task         |
| `cpauth`         | tagged roles, a `tasks:` section with `import_role`             |
| `core`           | multiple plays, `vars`, `pre_tasks`, list-valued tags, `when`   |
| `lxd`            | multi-host pattern (`hosts: ["a","b","c"]` -> `"a b c"`)         |
| `cpmeta`, `restheart`, `stiltweb` | play-level `tags`, proxy/host two-play split   |
| `server-fsicos2`, `server-icos1`  | long lists of tagged bootstrap roles           |
| `server-fsicos3` | a `when` over a built-in fact: `not("ansible_check_mode")`       |
| `all`            | `authorized_key` task referencing the `root_keys` var           |
| `prom-nextcloud` | `include_role` with `apply.tags` + task-level `vars`            |
| `prom-vmagent`   | role with a list param (`sexp_exporters`)                       |
| `vm-fsicos4-fdp` | `caddy` with a multiline literal-block param (`caddy_conf`)     |
| `server-cdb`     | `iptables_raw` task with a multiline `rules` block              |
| `util-remove`    | play `vars` + task names templated with `tmpl`                  |
| `vm-fsicos4-stiltcluster` | a `fetch` task + a guest-provisioning play             |
| `cpdata`         | certbot + `nginxsite` + parameterized `cpdata` + `dataold`      |

The rest (`drupal`, `typesense`, `plausible`, `sitesaquanetform`,
`app-fairdatapoint`, `nebula`, `bbservers`, `server-all`, `vm-fsicos4-pancake`,
`vm-fsicos4-cupcake`) are further single- or few-role playbooks.

## Usage

```bash
deno task check                      # type-check everything
deno task verify                     # render each playbook + diff vs ../devops/*.yml
deno task render playbooks/core.ts   # print the YAML for one playbook
```

`verify.ts` renders each `.ts` and compares it to the original `.yml` by parsing
**both** sides (with `npm:yaml`) and deep-comparing the data structures. Ansible
is insensitive to key order and to scalar style (`yes` vs `true`, folded vs plain
strings), so semantic equality — not byte equality — is the correct bar, and all
23 pass. Both sides are parsed as YAML **1.1** to match Ansible's PyYAML
(where `yes`/`no` are booleans, unlike YAML 1.2).

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
attach fluently with chainable `.tags()` / `.when()` (or `.opt({...})` for
several at once), keeping role *variables* and Ansible *keywords* visually
distinct:

```ts
role("icos.matomo")                                   // ok — no params
role("icos.keycloak", { kc_hostname: "..." })         // ok
role("icos.nexus").tags("nexus")                      // tags
role("icos.cpauth").when(isDefined("cpauth_envries")) // when
role("icos.virtuoso").tags("virtuoso").when(isDefined("virtuoso_enable").default(false))
role("icos.keycloak")                                 // error: vars required
role("icos.keycloak", { kc_hostnam: "..." })          // error: did you mean kc_hostname?
role("icos.kraken")                                   // error: unknown role
role("icos.dovecot", { dovecot_domains: "x" })        // error: expected string[]
```

All five mistake classes above are caught at `deno check` time, with TypeScript's
"Did you mean …?" suggestions.

### Variable references

Variables interpolated as `{{ ... }}` are the other silent-failure surface: a
typo'd `{{ nexus_hom }}` expands to nothing in Ansible. `lib/vars.ts` catalogues
the available variables and their types, and references go through checked
helpers instead of hand-written strings:

```ts
V.nexus_home                       // "{{ nexus_home }}"  (value position)
tmpl`${V.nexus_home}/bbclient`     // "{{ nexus_home }}/bbclient"  (composite)
isDefined("cpauth_domains")                  // "cpauth_domains is defined"  (when:)
isDefined("virtuoso_enable").default(false)  // "virtuoso_enable | default(False)"  (when:)
not("ansible_check_mode")                    // "not ansible_check_mode"  (when:, built-in)

V.nexus_hom                        // error: did you mean nexus_home?
tmpl`${"literal"}`                 // error: only checked refs may be interpolated
isDefined("cpauth_domian")         // error: not a known variable
```

`V` / `tmpl` cover value interpolation (with the `{{ }}` wrapper); `isDefined()`
(chainable with `.default(...)`) and `not()` cover the `when:` expression context
(bare name, no wrapper). Both accept any `VarName` — a user `Vars` entry **or** an
Ansible built-in from the `Builtins` registry (`lib/builtins.ts`). A `when:` is
typed `When = Expr`, with **no raw-string escape hatch** — every condition must be
built from a checked helper, so a misspelled variable in a `when` can't slip
through.

For value interpolation, because role-param fields are still plain `string`, a
raw `"{{ x }}"` also compiles — there `V`/`tmpl` make checked references
*available and ergonomic* rather than mandatory; a lint rule banning literal
`{{` would close that.

A future extension is splitting `Vars` by provenance (role-provided vs vault vs
`-e` extra-vars) to model which variables are actually in scope where.

### Hosts

A play's `hosts:` is typed as a closed `Host` union (`lib/hosts.ts`) of the
hosts and groups defined in `production.inventory`, plus the dynamic /
cross-inventory groups the playbooks target. Ansible runs a typo'd target
against zero hosts and exits successfully, so this catches a genuinely silent
failure:

```ts
{ hosts: "fsico2", ... }   // error: Type '"fsico2"' is not assignable to type 'Host'. Did you mean '"fsicos2"'?
```

`lib/hosts.ts` is derived from the inventory; regenerate it with:

```bash
python3 - <<'PY'
import glob, yaml, re
groups, hosts = set(), set()
def walk(d):
    if not isinstance(d, dict): return
    for g, body in d.items():
        groups.add(g)
        if isinstance(body, dict):
            for h in (body.get('hosts') or {}): hosts.add(h)
            walk(body.get('children') or {})
for f in glob.glob('../devops/production.inventory/*.yml'):
    try: data = yaml.safe_load(open(f))
    except Exception: continue
    if isinstance(data, dict): walk(data)
referenced=set()
for f in glob.glob('../devops/*.yml'):
    for line in open(f):
        m=re.match(r'\s*-?\s*hosts:\s*([A-Za-z0-9_,-]+)\s*$', line)
        if m: referenced.update(t.strip() for t in m.group(1).split(','))
for n in sorted(groups|hosts|referenced): print('  | "%s"' % n)
PY
```

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
