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
import type { Host, HostPattern } from "./hosts.ts";
import type { Expr } from "./vars.ts";

// Re-exported so playbooks reference variables/hosts from a single import.
export { and, Expr, isDefined, not, or, raw, type Ref, tmpl, V, type Vars } from "./vars.ts";
export { type Host, type HostPattern, pattern } from "./hosts.ts";
export type { Builtins } from "./builtins.ts";

/** A value that may carry a Jinja2 template, e.g. "{{ jre_apt_package }}". */
export type Tmpl = string;

/** A `when:` condition. Always a built `Expr` — build it with isDefined/not/etc. */
export type When = Expr;

/**
 * The set of Ansible tags used across the playbooks. Keeping this a closed
 * union catches typos at the type level; add a new tag here before using it.
 */
export type Tag =
  | "adduser"
  | "backup"
  | "bbclient"
  | "bbclient_radon"
  | "bbclient_ute"
  | "bbserver"
  | "caddy"
  | "cert"
  | "cpauth"
  | "cpauth_backup"
  | "cpauth_deploy"
  | "cpauth_proxy"
  | "cpauth_setup"
  | "cpdata"
  | "cpdata_proxy"
  | "cplog"
  | "cpmeta_proxy"
  | "dataold"
  | "dnsmasq"
  | "docker"
  | "doi_proxy"
  | "dokku"
  | "dokku_add_device"
  | "dovecot"
  | "eurocom"
  | "exploredata"
  | "export"
  | "fail2ban"
  | "fairdatapoint"
  | "fdp"
  | "filedrop"
  | "flexextract"
  | "flexpart"
  | "forward"
  | "future"
  | "guest"
  | "hba"
  | "host"
  | "howto"
  | "icos-cities"
  | "icos-ri"
  | "icosdata"
  | "incoming"
  | "inputdata"
  | "iptables"
  | "jbuild"
  | "jupyter"
  | "login"
  | "lxd"
  | "lxd_server"
  | "mailman"
  | "mkdir"
  | "mosh"
  | "mount"
  | "nebula"
  | "nextcloud"
  | "nexus"
  | "nfs"
  | "nginx"
  | "node"
  | "node_exporter"
  | "onlyoffice"
  | "opendkim"
  | "pgrep"
  | "podman"
  | "pool"
  | "postconf"
  | "postfix"
  | "postgis"
  | "postgresql"
  | "profile"
  | "project"
  | "prom"
  | "proxy"
  | "pve_server"
  | "python"
  | "python3"
  | "rdflog"
  | "rdflog_backup"
  | "registry"
  | "replica"
  | "restheart"
  | "restheart_proxy"
  | "root_keys"
  | "rspamd"
  | "rsyncd"
  | "script"
  | "server"
  | "setup"
  | "sftp"
  | "showauth"
  | "ssh"
  | "sshlogin"
  | "sshlogin_exploredata"
  | "static"
  | "stiltcluster"
  | "stiltrun"
  | "stiltweb"
  | "superuser"
  | "telegraf"
  | "users"
  | "utils"
  | "virtuoso"
  | "vm"
  | "vmagent"
  | "zfs";

/** Ansible tags: a single tag or a list. */
export type Tags = Tag | Tag[];

// --- Tasks -----------------------------------------------------------------

/**
 * A task. The keyword fields (name, tags, when, ...) are typed precisely — so a
 * raw-string `when`, a bad tag, or an unknown role name are caught. The action
 * module itself (shell, copy, lxd_container, ...) is one extra key whose body is
 * accepted as-is: Ansible has thousands of modules with ad-hoc argument shapes,
 * so they fall through the index signature rather than being enumerated.
 * `import_role`/`include_role` are typed because their `name` is a role.
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
  ignore_errors?: boolean;
  check_mode?: boolean;
  changed_when?: boolean | string | string[];
  failed_when?: boolean | string | string[];
  loop?: string | VarValue[];
  loop_control?: Record<string, VarValue>;
  with_items?: string | VarValue[];
  block?: Task[];
  args?: Record<string, VarValue>;
  vars?: Record<string, VarValue>;

  import_role?: string | { name: RoleName; tasks_from?: string };
  include_role?:
    | string
    | { name: RoleName; tasks_from?: string; apply?: { tags?: Tags }; public?: boolean };

  // Cross-file includes within a role: a sibling task file by name.
  import_tasks?: string;
  include_tasks?: string | { file: string; apply?: { tags?: Tags } };

  // Any other key is an action module; its argument shape is module-specific.
  [module: string]: unknown;
}

/** A role name: a known role, or any string (for roles not yet typed). */
type RoleName = keyof Roles | (string & {});

// --- Roles -----------------------------------------------------------------

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

export type Scalar = string | number | boolean;

export type VarValue =
  Scalar
  | VarValue[]
  | { [key: string]: VarValue };

export interface Play {
  /**
   * A single host/group; a YAML list of them (`Host[]`, rendered as a
   * sequence); or a space-separated `pattern(...)`.
   */
  hosts: Host | Host[] | HostPattern;
  tags?: Tags;
  vars?: Record<string, VarValue>;
  pre_tasks?: Task[];
  roles?: RoleBuilder[];
  tasks?: Task[];
  handlers?: Task[];
  become?: boolean;
  become_user?: string;
  gather_facts?: boolean;
  connection?: string;
}

/** A playbook is an ordered list of plays. */
export type Playbook = Play[];

/**
 * A role task/handler file: a bare ordered list of tasks (no play wrapper),
 * loaded by Ansible via `import_tasks`/`include_role`/a role's `main.yml`.
 */
export type TaskFile = Task[];

// --- Rendering -------------------------------------------------------------

/**
 * Render a playbook or a role task file to YAML identical (semantically) to the
 * hand-written `.yml`. `undefined` fields are dropped by JSON round-tripping so
 * optional keys never appear as `null`.
 */
export async function render(doc: Playbook | TaskFile): Promise<string> {
  const { stringify } = await import("npm:yaml@2");
  const clean = JSON.parse(JSON.stringify(doc));
  // Emit YAML 1.1 (like Ansible's PyYAML) so string scalars that look like 1.1
  // booleans — "yes"/"no"/"on"/"off" — are quoted rather than emitted bare
  // (which would reparse as booleans and diverge from the source).
  return stringify(clean, { version: "1.1", lineWidth: 0 });
}
