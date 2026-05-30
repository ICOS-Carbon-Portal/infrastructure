// Minimal, strongly-typed model of the slice of Ansible used by the top-level
// playbooks (the `devops/*.yml` files). The goal is to emit byte-for-byte
// equivalent YAML (semantically — Ansible is insensitive to key order) while
// catching typos and structural mistakes at the type level.
//
// Design choices that keep boilerplate low:
//   * Plays and tasks are plain typed object literals (`satisfies Play[]`),
//     so there is no wrapper noise — you write the data, TypeScript checks it.
//   * Only roles go through a builder (`role()`), because that is what unlocks
//     per-role parameter typing keyed off the role name.
import type { Roles } from "./roles.ts";
import type { Host } from "./hosts.ts";
import type { Expr } from "./vars.ts";

// Re-exported so playbooks reference variables/hosts from a single import.
export { Expr, isDefined, type Ref, tmpl, V, type Vars } from "./vars.ts";
export type { Host } from "./hosts.ts";

/** A value that may carry a Jinja2 template, e.g. "{{ jre_apt_package }}". */
export type Tmpl = string;

/** A `when:` condition: a raw expression string or a built `Expr`. */
export type When = Tmpl | Expr;

/**
 * The set of Ansible tags used across the playbooks. Keeping this a closed
 * union catches typos at the type level; add a new tag here before using it.
 */
export type Tag =
  | "nexus"
  | "bbclient"
  | "cert"
  | "cpauth"
  | "backup"
  | "postfix"
  | "dovecot"
  | "opendkim"
  | "postconf"
  | "proxy"
  | "cpmeta_proxy"
  | "cpdata_proxy"
  | "cpauth_proxy"
  | "restheart_proxy"
  | "doi_proxy"
  | "rdflog"
  | "rdflog_backup"
  | "postgis"
  | "virtuoso";

/** Ansible tags: a single tag or a list. */
export type Tags = Tag | Tag[];

// --- Tasks -----------------------------------------------------------------

/**
 * A task. The keyword fields (name, tags, when, ...) are common to every task;
 * the module fields (import_role, apt, ...) are the ones used by the converted
 * playbooks. Extend this union of optional modules as more playbooks adopt TS.
 */
export interface Task {
  name?: string;
  tags?: Tags;
  when?: When;
  become?: boolean;
  become_user?: string;
  register?: string;
  notify?: string | string[];
  delegate_to?: string;
  run_once?: boolean;
  vars?: Record<string, Scalar>;

  // Modules
  import_role?: { name: keyof Roles | (string & {}); tasks_from?: string };
  apt?: { name?: Tmpl | Tmpl[]; state?: string; update_cache?: boolean };
  postconf?: { param: string; value: string; reload?: boolean };
}

// --- Roles -----------------------------------------------------------------

export type Scalar = string | number | boolean;

/** Ansible role-keyword options (siblings of `role:`, not role variables). */
export interface RoleOpts {
  tags?: Tags;
  when?: When;
}

/** A flattened role reference as Ansible expects it: role + opts + variables. */
export type RoleRef = { role: string } & RoleOpts & Record<string, unknown>;

/**
 * A chainable role reference. Variables are fixed at construction (typed per
 * role); Ansible role-keyword options are attached fluently:
 *
 *   role("icos.nexus").tags("nexus")
 *   role("icos.cpauth").when(isDefined("cpauth_envries"))
 *   role("icos.virtuoso").tags("virtuoso").when(isDefined("virtuoso_enable").default(false))
 *
 * `toJSON()` emits the flat ref, so `render()`'s JSON round-trip drops the
 * methods and produces exactly the YAML Ansible expects.
 */
export class RoleBuilder {
  constructor(private readonly ref: RoleRef) {}

  /** Set `tags:` (a single tag or a list). */
  tags(tags: Tags): RoleBuilder {
    return new RoleBuilder({ ...this.ref, tags });
  }

  /** Set `when:` (a raw expression string or a built `Expr`). */
  when(when: When): RoleBuilder {
    return new RoleBuilder({ ...this.ref, when });
  }

  /** Set several role-keyword options at once. */
  opt(opts: RoleOpts): RoleBuilder {
    return new RoleBuilder({ ...this.ref, ...opts });
  }

  toJSON(): RoleRef {
    return this.ref;
  }
}

// When a role has no required variables, the vars argument is optional;
// otherwise it is mandatory. This is what makes `role("icos.matomo")` legal
// but `role("icos.keycloak")` a compile error (kc_hostname is required).
type RoleArgs<K extends keyof Roles> = {} extends Roles[K]
  ? [vars?: Roles[K]]
  : [vars: Roles[K]];

/**
 * Build a typed role reference. Variables are typed per role; attach tags/when
 * with the chainable `.tags()` / `.when()` helpers.
 *
 *   role("icos.keycloak", { kc_hostname: "keycloak.icos-cp.eu" })
 *   role("icos.nexus").tags("nexus")
 *   role("icos.matomo")
 */
export function role<K extends keyof Roles>(
  name: K,
  ...args: RoleArgs<K>
): RoleBuilder {
  const [vars] = args;
  return new RoleBuilder({ role: name, ...(vars ?? {}) });
}

// --- Plays -----------------------------------------------------------------

export interface Play {
  hosts: Host;
  vars?: Record<string, Scalar>;
  pre_tasks?: Task[];
  roles?: RoleBuilder[];
  tasks?: Task[];
  become?: boolean;
  gather_facts?: boolean;
}

/** A playbook is an ordered list of plays. */
export type Playbook = Play[];

// --- Rendering -------------------------------------------------------------

/**
 * Render a playbook to YAML identical (semantically) to the hand-written
 * `.yml`. `undefined` fields are dropped by JSON round-tripping so optional
 * keys never appear as `null`.
 */
export async function render(playbook: Playbook): Promise<string> {
  const { stringify } = await import("npm:yaml@2");
  const clean = JSON.parse(JSON.stringify(playbook));
  return stringify(clean, { lineWidth: 0 });
}
