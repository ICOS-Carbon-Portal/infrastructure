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
import { type Ref, Template, varProxy, type VarRef } from "./template.ts";

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
  concat,
  iff,
  jinjaFor,
  lookup,
  type LookupPlugin,
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

  /**
   * `| default(...)` filter; booleans render as Python `True`/`False`, strings
   * as `'quoted'` Jinja literals (matching Template.default / filterArgText).
   */
  default(fallback: Scalar): Expr {
    const rendered = typeof fallback === "boolean"
      ? fallback ? "True" : "False"
      : typeof fallback === "string"
      ? `'${fallback}'`
      : String(fallback);
    return new Expr(`${this.name} | default(${rendered})`, this.name);
  }

  toJSON(): string {
    return this.text;
  }
  toString(): string {
    return this.text;
  }

  /** `| bool` filter, applied to the full expression so far. */
  bool(): Expr {
    return new Expr(`${this.text} | bool`, this.name);
  }

  /**
   * Use this condition in a VALUE position (a `set_fact`, `become:`, a module
   * arg) as `{{ <expr> }}` — the value-position counterpart of the bare
   * when-condition rendering. Replaces `expr("a or b")`-style escapes:
   *
   *   or(_a.changed, _b.changed).asValue()  // {{ _a.changed or _b.changed }}
   */
  asValue(): Template {
    return new Template([{ kind: "ref", jinja: this.text }]);
  }
}

/** Any referenceable variable name: user `Vars`, globals, built-ins, or any role var. */
export type VarName = KnownName;

/**
 * An operand of a `when:` comparison/test. A `string`/`number`/`boolean` is a
 * LITERAL (a string renders `'quoted'`); a variable or expression reference —
 * `V.x` (a Template), a register field (`r.changed`), or another `Expr` —
 * renders BARE. This mirrors the value-combinator convention (iff/lookup), so
 * `eq(V.x, "y")` -> `x == 'y'`.
 */
export type Operand = Expr | Template | string | number | boolean;

/** A unary-test subject: a checked variable NAME, or a ref (`V.x`/register field). */
export type Subject = VarName | Expr | Template;

/** Bare text for a non-string operand (refs render bare). */
function refText(o: Exclude<Operand, string>): string {
  if (typeof o === "number") return String(o);
  if (typeof o === "boolean") return o ? "True" : "False";
  if (o instanceof Template) {
    const p = o.parts;
    if (p.length === 1 && p[0].kind === "ref") return p[0].jinja;
    if (p.length === 1 && p[0].kind === "raw") return p[0].text;
    return o.toText();
  }
  return String(o); // Expr, or a register-field proxy
}
/** Operand text: a bare string is a quoted literal. */
function operandText(o: Operand): string {
  return typeof o === "string" ? `'${o}'` : refText(o);
}
/** Subject text: a bare string is a variable NAME (rendered bare, not quoted). */
function subjText(s: Subject): string {
  return typeof s === "string" ? s : refText(s);
}

/** Start a `when:` test from a variable/ref: `<subject> is defined`. */
export function isDefined(s: Subject): Expr {
  const sub = subjText(s);
  return new Expr(`${sub} is defined`, sub);
}

/**
 * Negate a boolean variable, ref, or expression:
 *   not("ansible_check_mode")  -> "not ansible_check_mode"
 *   not(V.lxd_is_snap)         -> "not lxd_is_snap"
 *   not(r.failed)              -> "not r.failed"  (register result field)
 */
export function not(s: Subject): Expr {
  const sub = subjText(s);
  return new Expr(`not ${sub}`, sub);
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

/** `<subject> is not defined`. */
export function isNotDefined(s: Subject): Expr {
  const sub = subjText(s);
  return new Expr(`${sub} is not defined`, sub);
}

/** `<subject> is undefined` (a distinct rendering from `is not defined`). */
export function isUndefined(s: Subject): Expr {
  const sub = subjText(s);
  return new Expr(`${sub} is undefined`, sub);
}

/**
 * The variable whose NAME is held by `name`, via the magic `vars` dict:
 * `varByName(V.item)` -> `vars[item]`. Used in loop-driven required-parameter
 * guards: `when: isUndefined(varByName(V.item))`.
 */
export function varByName(name: Subject): Expr {
  const t = `vars[${subjText(name)}]`;
  return new Expr(t, t);
}

/** A bare variable/ref used directly as a truthiness condition: `<subject>`. */
export function truthy(s: Subject): Expr {
  const sub = subjText(s);
  return new Expr(sub, sub);
}

/** `<subject> is truthy`. */
export function isTruthy(s: Subject): Expr {
  const sub = subjText(s);
  return new Expr(`${sub} is truthy`, sub);
}

/** `<subject> is version('<version>', '<op>')`. */
export function isVersion(s: Subject, version: string, op: string): Expr {
  const t = `${subjText(s)} is version('${version}', '${op}')`;
  return new Expr(t, t);
}

/** `<a> == <b>` — strings are quoted literals; `V.x`/register refs render bare. */
export function eq(a: Operand, b: Operand): Expr {
  const t = `${operandText(a)} == ${operandText(b)}`;
  return new Expr(t, t);
}

/** `<a> != <b>`. */
export function ne(a: Operand, b: Operand): Expr {
  const t = `${operandText(a)} != ${operandText(b)}`;
  return new Expr(t, t);
}

/** `<a> < <b>` — e.g. `lt(r.msg.find('x'), 0)` -> `r.msg.find('x') < 0`. */
export function lt(a: Operand, b: Operand): Expr {
  const t = `${operandText(a)} < ${operandText(b)}`;
  return new Expr(t, t);
}

/** `<a> > <b>`. */
export function gt(a: Operand, b: Operand): Expr {
  const t = `${operandText(a)} > ${operandText(b)}`;
  return new Expr(t, t);
}

/** `<a> <= <b>`. */
export function lte(a: Operand, b: Operand): Expr {
  const t = `${operandText(a)} <= ${operandText(b)}`;
  return new Expr(t, t);
}

/** `<a> >= <b>`. */
export function gte(a: Operand, b: Operand): Expr {
  const t = `${operandText(a)} >= ${operandText(b)}`;
  return new Expr(t, t);
}

/** A collection: a ref (`V.x` -> bare) or an array rendered as a `('a', 'b')` tuple. */
function collText(coll: Operand | Operand[]): string {
  return Array.isArray(coll)
    ? `(${coll.map(operandText).join(", ")})`
    : operandText(coll);
}

/** `<item> in <coll>`. */
export function isIn(item: Operand, coll: Operand | Operand[]): Expr {
  const t = `${operandText(item)} in ${collText(coll)}`;
  return new Expr(t, t);
}

/** `<item> not in <coll>`. */
export function notIn(item: Operand, coll: Operand | Operand[]): Expr {
  const t = `${operandText(item)} not in ${collText(coll)}`;
  return new Expr(t, t);
}

/** Parenthesize for precedence: `(<e>)` — e.g. `not(group(... | bool))`. */
export function group(e: Expr): Expr {
  const t = `(${e})`;
  return new Expr(t, t);
}
