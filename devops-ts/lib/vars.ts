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
  virtuoso_enable: boolean;
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

import type { Scalar, Tmpl } from "./ansible.ts";
import type { Builtins } from "./builtins.ts";

/** A checked variable reference. At runtime it is just the string "{{ name }}". */
export type Ref = string & { readonly __ref: unique symbol };

/**
 * Typed accessor for variable references in value position.
 *
 *   V.nexus_home            // "{{ nexus_home }}"
 *   V.nope                  // compile error: not in Vars
 */
export const V: { readonly [K in keyof Vars]: Ref } = new Proxy(
  {},
  { get: (_t, name: string) => `{{ ${name} }}` },
) as { readonly [K in keyof Vars]: Ref };

/**
 * Build a composite templated string. Only known refs may be interpolated, so
 * `tmpl`${V.foo}/x`` is checked but `tmpl`${"foo"}`` is rejected.
 *
 *   tmpl`${V.nexus_home}/bbclient`   // "{{ nexus_home }}/bbclient"
 */
export function tmpl(strings: TemplateStringsArray, ...refs: Ref[]): Tmpl {
  return strings.reduce(
    (acc, part, i) => acc + part + (i < refs.length ? refs[i] : ""),
    "",
  );
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

/** Any referenceable variable name: a user `Vars` entry or an Ansible built-in. */
export type VarName = keyof Vars | keyof Builtins;

/** Start a `when:` expression from a variable: `name is defined`. */
export function isDefined(name: VarName): Expr {
  return new Expr(`${name} is defined`, name as string);
}

/** Negate a boolean variable: `not("ansible_check_mode")` -> "not ansible_check_mode". */
export function not(name: VarName): Expr {
  return new Expr(`not ${name}`, name as string);
}
