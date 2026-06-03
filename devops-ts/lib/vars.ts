// Typed catalogue of the Ansible variables the playbooks may reference, plus
// checked helpers for referencing them. This is the counterpart to roles.ts:
// roles.ts types what a role *accepts*, this types what playbooks may *read*.
//
// A bare `{{ nexus_hom }}` typo expands to nothing in Ansible and fails
// silently; routing every reference through `V` / `tmpl` / the expression
// helpers turns that into a compile error.
//
// Adoption is incremental: add a variable here when a converted playbook first
// references it. Grouping is by origin, for documentation only.
export interface Vars {
  // Provided by a role (defaults/vars), readable by later roles/tasks.
  nexus_home: string; // icos.nexus

  // Supplied at runtime (`-e`), or from vault / inventory.
  cpauth_cert_name: string;
  cpauth_domains: string;
  cpdata_cert_name: string;
  cpdata_domains: string;
  doi_certbot_name: string;
  cpauth_envries: string; // list of "envri" items (cf. icos.cpauth template loop)
  root_keys: string; // global: the ssh keys each host authorizes for root
  icosdata_exports: string;
  icosdata_nfs_mounts: string;
  stilt_input_mount: boolean;

  // Defined in a play's `vars:` block (see core.ts, util-remove.ts).
  jre_apt_package: string;
  java_path: string;
  nginxsite_name: string;
  lxd_vm_name: string;
}

import type { Scalar } from "./ansible.ts";
import type { BuiltinVars } from "./builtins.ts";
import type { Globals } from "./globals.ts";
import type { AllVars } from "./allvars.ts";
import type { ParamVars } from "./paramvars.ts";
import type { VaultVars } from "./vaultvars.ts";
import type { VarShapes } from "./shapes.ts";
import { type Ref, varProxy, type VarRef } from "./template.ts";

// The full set of statically-known variables a playbook may reference: the
// hand-curated `Vars` above, plus globals/inventory vars, Ansible built-ins,
// every role-defined var (lib/allvars.ts), role caller-params / play vars
// (lib/paramvars.ts), vault-defined names (lib/vaultvars.ts), and object
// shapes (lib/shapes.ts). Ansible variable names are a single flat namespace,
// so a name defined anywhere is the same variable everywhere — referencing it
// through a checked `V.x` (not `expr("x")`) catches typos.
// The generated registries declare every value as `unknown`, so a name that is
// also hand-declared (a fact shape, a boolean global) intersects to the
// hand-declared type rather than to a `never`-valued property.
type AllKnown =
  & Vars
  & Globals
  & BuiltinVars
  & AllVars
  & ParamVars
  & VaultVars
  & VarShapes;
type KnownName = keyof AllKnown & string;

// Re-exported for convenience (the canonical definitions live in template.ts).
export {
  expr,
  RawTemplate,
  rawTmpl,
  type Ref,
  Template,
  type Tmpl,
  tmpl,
} from "./template.ts";

/**
 * Typed accessor for variable references in value position. Each access yields a
 * `Template` (rendered quoted), so unknown names are a compile error. A variable
 * declared with an object shape (lib/shapes.ts) exposes checked field refs.
 *
 *   V.nexus_home            // Template "{{ nexus_home }}"
 *   V.wg_hub_config.name    // Template "{{ wg_hub_config.name }}"
 *   V.nope                  // compile error: not in Vars
 */
export const V: { readonly [K in KnownName]: VarRef<AllKnown[K]> } = new Proxy(
  {},
  { get: (_t, name: string) => varProxy(name) },
) as { readonly [K in KnownName]: VarRef<AllKnown[K]> };

/**
 * Checked access to another host's variables:
 *   hostvar(V.jbuild_rsync_host).ansible_port  // {{ hostvars[jbuild_rsync_host].ansible_port }}
 *   hostvar("localhost").some_fact             // {{ hostvars.localhost.some_fact }}
 * The host is a variable ref (rendered as `hostvars[<name>]`) or a literal
 * hostname (rendered as `hostvars.<host>`); the field is any known variable.
 */
export function hostvar(
  host: Ref | string,
): { readonly [K in KnownName]: Ref } {
  const path = typeof host === "string"
    ? `hostvars.${host}`
    : `hostvars[${host.parts[0].kind === "ref" ? host.parts[0].jinja : host}]`;
  return varProxy(path) as unknown as { readonly [K in KnownName]: Ref };
}

// --- when: expression builder (bare name, no `{{ }}` wrapper) ----------------

/**
 * A Jinja expression over a variable, for use in `when:`. It renders as its
 * text (via `toJSON`, so it survives `render()`'s JSON round-trip), and offers
 * chainable filters:
 *
 *   isDefined("cpauth_domains")              // "cpauth_domains is defined"
 *   isDefined("virtuoso_enable").default(false)  // "virtuoso_enable | default(False)"
 */
export class Expr {
  constructor(
    private readonly text: string,
    private readonly name: string,
  ) {}

  /** `| default(...)` filter; booleans render as Python `True`/`False`. */
  default(fallback: Scalar): Expr {
    const rendered = typeof fallback === "boolean"
      ? fallback ? "True" : "False"
      : String(fallback);
    return new Expr(`${this.name} | default(${rendered})`, this.name);
  }

  toJSON(): string {
    return this.text;
  }
  toString(): string {
    return this.text;
  }
}

/** Any referenceable variable name: user `Vars`, globals, built-ins, or any role var. */
export type VarName = KnownName;

/** Start a `when:` expression from a variable: `name is defined`. */
export function isDefined(name: VarName): Expr {
  return new Expr(`${name} is defined`, name as string);
}

/**
 * Negate a boolean variable or expression:
 *   not("ansible_check_mode")  -> "not ansible_check_mode"
 *   not(r.failed)              -> "not r.failed"  (register result field)
 */
export function not(name: VarName): Expr;
export function not(expr: Expr): Expr;
export function not(arg: VarName | Expr): Expr {
  const text = typeof arg === "string" ? arg : String(arg);
  return new Expr(`not ${text}`, text);
}

/**
 * An explicit, auditable escape for `when:` expressions the typed helpers do not
 * model — comparisons (`==`, `in`), filters (`| bool`), attribute access on
 * registered results (`_conf.changed`) or loop items (`item.x`). Role task files
 * are dense with these. Unlike the removed *implicit* string→`When` coercion,
 * `raw()` is a deliberate, greppable call: `grep -r 'raw(' shows every escape.
 *
 *   raw('ansible_distribution == "Debian"')
 *   raw("cpauth_jar_file is defined")
 */
export function raw(text: string): Expr {
  return new Expr(text, text);
}

/** Join expressions with Jinja `and`: `and(a, b)` -> "a and b". */
export function and(...exprs: Expr[]): Expr {
  const text = exprs.map(String).join(" and ");
  return new Expr(text, text);
}

/** Join expressions with Jinja `or`: `or(a, b)` -> "a or b". */
export function or(...exprs: Expr[]): Expr {
  const text = exprs.map(String).join(" or ");
  return new Expr(text, text);
}
