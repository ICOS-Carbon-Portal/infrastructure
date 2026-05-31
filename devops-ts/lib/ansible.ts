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
import type {
  AptArgs,
  AuthorizedKeyArgs,
  BlockinfileArgs,
  CopyArgs,
  CronArgs,
  DebugArgs,
  FailArgs,
  FileArgs,
  GetUrlArgs,
  GitArgs,
  LineinfileArgs,
  PackageArgs,
  PipArgs,
  ServiceArgs,
  SetFactArgs,
  ShellArgs,
  StatArgs,
  SystemdArgs,
  TemplateArgs,
  UnarchiveArgs,
  UriArgs,
  UserArgs,
} from "./modules.ts";

// Re-exported so playbooks reference variables/hosts from a single import.
export {
  and,
  Expr,
  isDefined,
  not,
  or,
  raw,
  type Ref,
  tmpl,
  V,
  type Vars,
} from "./vars.ts";
export { type Host, type HostPattern, pattern } from "./hosts.ts";
export type { Builtins } from "./builtins.ts";
export { type Item, loopOver, withItemsOver } from "./loop.ts";
export { type Reg, register, type Result } from "./register.ts";

/** A value that may carry a Jinja2 template, e.g. "{{ jre_apt_package }}". */
export type Tmpl = string;

/**
 * A `when:` condition. A built `Expr` (never a raw string — build it with
 * isDefined/not/raw/etc.), or a list of them for YAML's list-form `when:` where
 * Ansible ANDs the entries.
 */
export type When = Expr | Expr[];

/**
 * The set of Ansible tags used across the playbooks. Keeping this a closed
 * union catches typos at the type level; add a new tag here before using it.
 */
export type Tag =
  | "adduser"
  | "alias"
  | "always"
  | "auto_dnat"
  | "backup"
  | "bbclient"
  | "bbclient_coldbackup"
  | "bbclient_just"
  | "bbclient_radon"
  | "bbclient_repos"
  | "bbclient_scripts"
  | "bbclient_ssh"
  | "bbclient_timer"
  | "bbclient_ute"
  | "bbserver"
  | "bbserver_cli"
  | "bbserver_compact"
  | "bbserver_monitor"
  | "bbserver_setup"
  | "borg"
  | "borg_just"
  | "btop"
  | "caddy"
  | "caddy_just"
  | "caddy_modules"
  | "caddy_site"
  | "caddy_xcaddy"
  | "cert"
  | "certbot_only"
  | "certbot_utils"
  | "conf"
  | "cpauth"
  | "cpauth_backup"
  | "cpauth_deploy"
  | "cpauth_proxy"
  | "cpauth_setup"
  | "cpdata"
  | "cpdata_config"
  | "cpdata_deploy"
  | "cpdata_proxy"
  | "cpdata_setup"
  | "cplog"
  | "cpmeta"
  | "cpmeta_backup"
  | "cpmeta_deploy"
  | "cpmeta_proxy"
  | "cpmeta_restart"
  | "cpmeta_setup"
  | "ctop"
  | "dataold"
  | "dive"
  | "dnsmasq"
  | "dnsmasq_config"
  | "dnsmasq_hosts"
  | "dnsmasq_setup"
  | "docker"
  | "docker_cleanup"
  | "docker_just"
  | "docker_login"
  | "docker_test"
  | "docker_utils"
  | "doi_deploy"
  | "doi_proxy"
  | "doi_setup"
  | "dokku"
  | "dokku_add_device"
  | "dokku_install"
  | "dokku_just"
  | "dovecot"
  | "dovecot_fail2ban"
  | "dovecot_logging"
  | "dovecot_ssl"
  | "drupal"
  | "drupal_backup"
  | "drupal_nginx"
  | "eurocom"
  | "exploredata"
  | "export"
  | "fail2ban"
  | "fail2ban_config"
  | "fail2ban_just"
  | "fail2ban_setup"
  | "fairdatapoint"
  | "fairdatapoint_setup"
  | "fd"
  | "fdp"
  | "fetch"
  | "filedrop"
  | "flexextract"
  | "flexextract_build"
  | "flexextract_script"
  | "flexextract_sync"
  | "flexpart"
  | "flexpart_only"
  | "flexpart_run"
  | "flexpart_ssh"
  | "forward"
  | "future"
  | "geoip_app"
  | "geoip_certbot"
  | "geoip_check"
  | "geoip_nginx"
  | "geoip_setup"
  | "grafana_datasource"
  | "guest"
  | "hba"
  | "host"
  | "howto"
  | "httm"
  | "icos-cities"
  | "icos-ri"
  | "icosdata"
  | "incoming"
  | "initialize_collection"
  | "inputdata"
  | "iptables"
  | "jarservice_jarfile"
  | "jbuild"
  | "jbuild_edctl"
  | "jbuild_jbuild"
  | "jbuild_jyctl"
  | "jbuild_rsync"
  | "jbuild_users"
  | "jupyter"
  | "jupyter_jusers"
  | "jupyter_just"
  | "jupyter_registry"
  | "jupyter_setup"
  | "just"
  | "keys"
  | "lazydocker"
  | "lazygit"
  | "lockuser"
  | "login"
  | "lxd"
  | "lxd_guest_setup"
  | "lxd_limits"
  | "lxd_server"
  | "lxd_sysctl"
  | "lxd_utils"
  | "lxd_vm_forward"
  | "mailman"
  | "mailman_delete_spam"
  | "mailman_just"
  | "mkdir"
  | "mosh"
  | "mount"
  | "ncdu"
  | "nebula"
  | "nebula_ca"
  | "nebula_cert"
  | "nebula_config"
  | "nebula_hosts"
  | "nebula_install"
  | "nebula_iptables"
  | "nebula_just"
  | "nebula_resolve"
  | "nebula_service"
  | "nebula_ssh"
  | "nebula_test"
  | "nextcloud"
  | "nextcloud_just"
  | "nextcloud_nginx"
  | "nextcloud_prometheus"
  | "nextcloud_setup"
  | "nexus"
  | "nexus_docker"
  | "nexus_nginx"
  | "nfs"
  | "nfs4_just"
  | "nginx"
  | "nginx_certbot"
  | "nginx_conf"
  | "nginx_metrics"
  | "nginx_setup"
  | "nginx_testing"
  | "nginxforward_auth"
  | "nginxsite_cert"
  | "nginxsite_users"
  | "node"
  | "node_exporter"
  | "onlyoffice"
  | "onlyoffice_docker"
  | "onlyoffice_install_fonts"
  | "onlyoffice_just"
  | "opendkim"
  | "pgrep"
  | "podman"
  | "podman_cni_plugins"
  | "podman_configure"
  | "podman_conmon"
  | "podman_docker"
  | "podman_install"
  | "podman_utils"
  | "pool"
  | "postconf"
  | "postfix"
  | "postfix_fail2ban"
  | "postgis"
  | "postgis_backup"
  | "postgis_just"
  | "postgis_restore_script"
  | "postgis_setup"
  | "postgresql"
  | "postgresql_config"
  | "postgresql_install"
  | "postgresql_pg_stat"
  | "postgresql_util"
  | "profile"
  | "project"
  | "prom"
  | "proxy"
  | "pull"
  | "pve_guest_setup"
  | "pve_guest_terminal"
  | "pve_server"
  | "pve_server_just"
  | "python"
  | "python3"
  | "quince-backup"
  | "quince-backup-script"
  | "quince-logging"
  | "quince-mysql"
  | "quince-setup"
  | "quince-system"
  | "quince-tomcat"
  | "rdflog"
  | "rdflog_backup"
  | "rdflog_restore"
  | "rdflog_setup"
  | "registry"
  | "registry_auth"
  | "remove"
  | "replica"
  | "repo"
  | "restheart"
  | "restheart_backup"
  | "restheart_proxy"
  | "restheart_restore_script"
  | "restheart_setup"
  | "restic"
  | "restic_install"
  | "restic_server_auth"
  | "restic_server_just"
  | "restic_server_setup"
  | "restic_server_systemd"
  | "ripgrep"
  | "root_keys"
  | "rspamd"
  | "rspamd_config"
  | "rspamd_install"
  | "rspamd_just"
  | "rspamd_pyzor"
  | "rspamd_redis"
  | "rspamd_unbound"
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
  | "stiltcluster_config"
  | "stiltcluster_deploy"
  | "stiltcluster_setup"
  | "stiltcluster_timer"
  | "stiltrun"
  | "stiltweb"
  | "stiltweb_deploy"
  | "stiltweb_just"
  | "stiltweb_setup"
  | "stiltweb_sync"
  | "stiltweb_utils"
  | "superuser"
  | "sysstat"
  | "telegraf"
  | "telegraf_config"
  | "telegraf_install"
  | "telegraf_just"
  | "telegraf_smart"
  | "timer"
  | "trippy"
  | "update_documents"
  | "update_synonyms"
  | "users"
  | "utils"
  | "utils_copy"
  | "uv"
  | "victoriametrics_just"
  | "virtuoso"
  | "vm"
  | "vmagent"
  | "vmagent_install"
  | "vmagent_just"
  | "vmagent_proxy"
  | "vmagent_systemd"
  | "watchexec"
  | "wg_hub_ping"
  | "zfs"
  | "zfs_just"
  | "zfsdocker"
  | "zrepl_config"
  | "zrepl_install"
  | "zrepl_just"
;

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
  become?: boolean | string;
  become_user?: string;
  register?: string;
  notify?: string | string[];
  delegate_to?: string;
  run_once?: boolean;
  ignore_errors?: boolean;
  check_mode?: boolean;
  // Condition fields accept an `Expr` too, so register-result fields
  // (`r.failed`) and `not(...)` compose into them.
  changed_when?: boolean | string | string[] | Expr;
  failed_when?: boolean | string | string[] | Expr;
  until?: string | Expr;
  loop?: string | VarValue[];
  loop_control?: Record<string, VarValue>;
  with_items?: string | VarValue[];
  block?: Task[];
  args?: Record<string, VarValue>;
  vars?: Record<string, VarValue>;

  import_role?: string | { name: RoleName; tasks_from?: string };
  include_role?:
    | string
    | {
      name: RoleName;
      tasks_from?: string;
      apply?: { tags?: Tags };
      public?: boolean;
    };

  // Cross-file includes within a role: a sibling task file by name.
  import_tasks?: string;
  include_tasks?: string | { file: string; apply?: { tags?: Tags } };

  // Top modules: typed (a superset of real usage). FQCN aliases share the type.
  // Some accept Ansible's `key=value` string shorthand in addition to a mapping.
  file?: FileArgs | string;
  copy?: CopyArgs;
  "ansible.builtin.copy"?: CopyArgs;
  template?: TemplateArgs;
  "ansible.builtin.template"?: TemplateArgs;
  systemd?: SystemdArgs;
  service?: ServiceArgs;
  apt?: AptArgs;
  "ansible.builtin.package"?: PackageArgs;
  command?: string;
  shell?: ShellArgs;
  "ansible.builtin.shell"?: ShellArgs;
  debug?: DebugArgs;
  set_fact?: SetFactArgs;
  fail?: FailArgs;
  user?: UserArgs;
  uri?: UriArgs;
  stat?: StatArgs;
  get_url?: GetUrlArgs;
  "ansible.builtin.get_url"?: GetUrlArgs;
  unarchive?: UnarchiveArgs;
  pip?: PipArgs;
  "ansible.builtin.pip"?: PipArgs;
  blockinfile?: BlockinfileArgs;
  lineinfile?: LineinfileArgs;
  cron?: CronArgs;
  git?: GitArgs;
  authorized_key?: AuthorizedKeyArgs;

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
type RoleArgs<K extends keyof Roles> = {} extends Roles[K] ? [vars?: Roles[K]]
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
  | Scalar
  | null
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
  vars_files?: string | string[];
  pre_tasks?: Task[];
  roles?: RoleBuilder[];
  tasks?: Task[];
  handlers?: Task[];
  become?: boolean | string;
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
