// Per-role variable contexts.
//
// A role's task files reference variables. Only ~half are defined in the role's
// own `defaults/` (the rest are caller params, registered results, loop items,
// set_fact outputs, globals — see ROLES_PLAN.md). This module turns the
// statically-known half into a typed, autocompleted accessor; the dynamic rest
// keep using raw "{{ }}" strings and raw() exactly as before.
//
// Each role gets a generated `roles/<role>/_ctx.ts` that calls `context<Vars>()`
// with that role's variable interface and re-exports the result. A task file
// then does:
//
//   import { V, tmpl, isDef } from "./_ctx.ts";
//   copy: { dest: tmpl`${V.cpauth_home}/application.conf` }   // checked
//   when: isDef("cpauth_jar_file")                            // checked name
//
// Adoption is incremental and per-reference: convert the references whose names
// the context knows; leave the dynamic ones as raw strings.
import type { Tmpl } from "./ansible.ts";
import { Expr, type Ref } from "./vars.ts";

/** The accessor bundle a role context exposes, scoped to that role's vars `V`. */
export interface Context<V> {
  /** Typed reference accessor: `V.foo` -> "{{ foo }}". Unknown names error. */
  V: { readonly [K in keyof V]: Ref };
  /** Composite template; only this role's refs may be interpolated. */
  tmpl: (strings: TemplateStringsArray, ...refs: Ref[]) => Tmpl;
  /** `when:` builder over a known var name: `isDef("foo")` -> "foo is defined". */
  isDef: (name: keyof V & string) => Expr;
  /** `when:` builder: `notVar("foo")` -> "not foo". */
  notVar: (name: keyof V & string) => Expr;
}

/**
 * Build a role-scoped variable context from a role's variable interface.
 *
 *   const { V, tmpl, isDef } = context<CpauthVars>();
 */
export function context<V>(): Context<V> {
  const Vproxy = new Proxy({}, {
    get: (_t, name: string) => `{{ ${name} }}`,
  }) as { readonly [K in keyof V]: Ref };

  const tmpl = (strings: TemplateStringsArray, ...refs: Ref[]): Tmpl =>
    strings.reduce(
      (acc, part, i) => acc + part + (i < refs.length ? refs[i] : ""),
      "",
    );

  const isDef = (name: keyof V & string): Expr =>
    new Expr(`${name} is defined`, name);

  const notVar = (name: keyof V & string): Expr =>
    new Expr(`not ${name}`, name);

  return { V: Vproxy, tmpl, isDef, notVar };
}
