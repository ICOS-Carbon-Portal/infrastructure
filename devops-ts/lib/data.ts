// Types for the non-executable data files (defaults, vars, inventory,
// host_vars/group_vars, role meta). These are value files, not logic — the
// goal is a typed TS module that renders back to the identical YAML.
//
// `meta/main.yml` gets real checking (role names against the registry, tags
// against the Tag union); the rest are value maps typed permissively, since the
// *names* are already typed elsewhere (per-role _ctx.ts, hosts.ts, globals.ts)
// and the values are arbitrary scalars/templates.
import type { Roles } from "./roles.ts";
import type { Tags } from "./ansible.ts";
import type { VarValue } from "./ansible.ts";

/** A role dependency in `meta/main.yml`. The role must be a known role. */
export interface RoleDep {
  role: keyof Roles;
  tags?: Tags;
  when?: string;
  vars?: Record<string, VarValue>;
}

/** `roles/<role>/meta/main.yml`. */
export interface Meta {
  dependencies?: RoleDep[];
  galaxy_info?: Record<string, VarValue>;
  allow_duplicates?: boolean;
}

/** A plain variable map (defaults, vars, host_vars, group_vars). */
export type VarsFile = Record<string, VarValue>;

/** An Ansible inventory tree (groups -> {hosts, children, vars}). */
export type Inventory = Record<string, VarValue>;
