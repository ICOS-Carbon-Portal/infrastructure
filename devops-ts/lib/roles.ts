// Typed parameter schemas for Ansible roles.
//
// This is the heart of the type-safety story: each role declares exactly which
// variables it accepts and their types. `role("icos.keycloak", { ... })` then
// autocompletes the variable names and rejects unknown / mistyped ones.
//
// Adoption is incremental: when you convert a playbook that uses a role not yet
// listed here, add its schema. Roles with no parameters map to `{}` and can be
// referenced as a bare `role("icos.matomo")`.
//
// `Tmpl` documents that a value may be (or contain) a Jinja2 template string
// like "{{ nexus_home }}/bbclient" — still just a string at the type level, but
// self-documenting at call sites.
export type Tmpl = string;

import type { VarValue } from "./ansible.ts";

// A role ref may carry a `vars:` block (a sibling of `role:`) and/or a display
// `name:`; both are allowed on any role in addition to its own variables.
type Common = { name?: string; vars?: Record<string, VarValue> };

// A disk device passed to icos.lxd_vm (`recursive`/`readonly` are LXC's stringy
// "true"/"false"). Keyed by device name.
type LxdDevice = {
  path: string;
  source: string;
  type: string;
  recursive?: string;
  readonly?: string;
};

type NoVars = Record<PropertyKey, never>;

export interface Roles {
  "icos.keycloak": { kc_hostname: string };
  "icos.matomo": NoVars;
  "icos.geoip": NoVars;
  "icos.nexus": NoVars;

  // Used across many playbooks with different subsets of vars, so all optional.
  "icos.bbclient2": Common & {
    bbclient_name?: string;
    bbclient_user?: string;
    bbclient_home?: Tmpl;
    bbclient_coldbackup?: Tmpl;
    bbclient_coldbackup_hour?: number;
    bbclient_coldbackup_minute?: number;
    bbclient_remotes?: string[];
    bbclient_timer_content?: string;
    bbclient_patterns?: string;
  };

  "icos.certbot2": {
    certbot_name?: Tmpl;
    certbot_domains?: Tmpl | string[];
  };

  "icos.cpauth": NoVars;

  "icos.postfix": {
    postfix_config_list: { param: string; value: string }[];
  };
  "icos.dovecot": { dovecot_domains: string[] };
  "icos.opendkim": {
    opendkim_domains: string[];
    opendkim_domains_testkeys?: string[];
  };

  // core.yml
  "icos.postgis": NoVars;
  "icos.restheart": NoVars;
  "icos.cpmeta": Common & {
    cpmeta_filestorage_target?: string;
    cpmeta_jar_file?: string;
    cpmeta_config_files?: string[];
  };
  "icos.cpdata": { cpdata_netcdf_folder?: string };
  "icos.doi": NoVars;
  "icos.virtuoso": NoVars;
  "icos.nginxsite": Common & {
    nginxsite_name?: string;
    nginxsite_file?: string;
    nginxsite_users?: { username: string; password: string }[];
    registry_host?: string;
    registry_cert?: string;
    registry_allow?: string;
    dokku_proxy_host?: string;
    dokku_proxy_port?: number;
    jupyter_domain?: string;
    jupyter_cert_name?: string;
    jupyter_port?: number;
  };
  "icos.dataold": NoVars;

  // single-app playbooks (no role-level variables)
  "icos.maps": NoVars;
  "icos.drupal": NoVars;
  "icos.typesense": NoVars;
  "icos.plausible": NoVars;
  "icos.sitesaquanetform": NoVars;
  "icos.fairdatapoint": NoVars;
  "icos.nebula": NoVars;
  "icos.stiltweb": NoVars;
  "icos.telegraf": { telegraf_conf: string };
  "icos.mailman": NoVars;
  "icos.exploredata": NoVars;
  "icos.rspamd": NoVars;
  "icos.dokku": NoVars;
  "icos.flexpart": { flexpart_install_run?: boolean };
  "icos.flexextract": {
    flexextract_src_dir: string;
    flexextract_download_host: string;
  };
  "icos.eurocom": {
    eurocom_users: string;
    eurocom_web_root: string;
    eurocom_data_home: string;
  };
  "icos.filedrop": { filedrop_data_home: string };
  "icos.nextcloud": {
    nextcloud_admin_password: string;
    nextcloud_domain: string;
    nextcloud_exporter_pass: string;
    nextcloud_volumes: string[];
  };
  "icos.onlyoffice": { onlyoffice_domain: string; onlyoffice_secret: string };
  "icos.registry": { registry_users: string };
  "icos.victoriametrics": {
    vm_graf_domain: string;
    vm_graf_pass: string;
    vm_promlens_token: string;
  };
  "icos.jbuild": {
    jbuild_users: string;
    jbuild_registry_pass: string;
    jbuild_edctl_host: string;
    jbuild_edctl_host_name: string;
    jbuild_edctl_host_port: number;
    jbuild_rsync_host: string;
    jbuild_rsync_host_port: number;
    jbuild_rsync_host_name: string;
    jbuild_jyctl_host: string;
    jbuild_jyctl_host_port: number;
    jbuild_jyctl_host_name: string;
  };
  "icos.jupyter": Common & {
    jupyter_admins?: string | null;
    jupyter_user_volumes?: string;
    jupyter_backup_enable?: boolean;
    jupyter_jusers_enable?: boolean;
    jupyter_hub_config?: {
      admin_users?: string | string[];
      mem_limit?: string;
      cpu_limit?: number;
    };
    bbclient_name?: string;
  };

  // server bootstrap roles
  "icos.server": NoVars;
  "icos.docker": {
    docker_periodic_cleanup?: boolean;
    docker_prevent_upgrade?: boolean;
  };
  "icos.docker2": NoVars;
  "icos.nginx": NoVars;
  "icos.nfs4": NoVars;
  "icos.lxd_server": NoVars;
  "icos.podman": NoVars;
  "icos.caddy": { caddy_name?: string; caddy_conf?: string };
  "icos.bbserver": NoVars;
  "icos.mosh": NoVars;
  "icos.pve_server": NoVars;
  "icos.users": NoVars;
  "icos.rdflog": Common & {
    rdflog_postgres_version?: number;
    rdflog_rep_pass?: string;
    rdflog_restore_file?: string;
  };
  "icos.pgrep": NoVars;
  "icos.fail2ban": {
    fail2ban_config_files: { dest: string; content: string }[];
  };
  "icos.dnsmasq": { dnsmasq_interface: string; dnsmasq_config: string };
  "icos.rsyncd": {
    rsyncd_enable: boolean;
    rsyncd_users: { name: string }[];
    rsyncd_conf: string;
  };
  "icos.superuser": {
    superuser_disable_coredump?: boolean;
    superuser_list: { name: string; key: string }[];
  };
  "ops.zfs": NoVars;

  // lxd / vm provisioning
  "icos.lxd_vm": Common & {
    lxd_vm_name?: string;
    lxd_vm_docker?: boolean;
    lxd_vm_docker_size?: string;
    lxd_vm_root_size?: string;
    lxd_vm_root_pool?: string;
    lxd_vm_ubuntu_version?: string;
    lxd_vm_config?: Record<string, string>;
    lxd_vm_devices?: Record<string, LxdDevice>;
    lxd_vm_profiles?: string[];
  };
  "icos.lxd_guest": { user_conf?: string; user_disable_coredump?: boolean };
  "icos.lxd_forward": { lxd_forward_ip: string; lxd_forward_name: string };
  "icos.nginxforward": {
    nginxforward_name: string;
    nginxforward_host: string;
    nginxforward_port: number;
    nginxforward_cert: string;
    nginxforward_domains: string[];
  };
  "icos.sshlogin": {
    sshlogin_dst?: string;
    sshlogin_src_user: string;
    sshlogin_dst_user: string;
    sshlogin_src_dst_name?: string;
  };
  "icos.sftp_user": {
    sftp_user_dir: string;
    sftp_user_login: string;
    sftp_user_password: string;
    sftp_user_owner?: string;
    sftp_user_hostdesc?: string;
  };

  // VM guest + utility roles
  "icos.pve_guest": NoVars;
  "icos.utils": NoVars;
  "icos.python3": NoVars;
  "icos.stiltrun": NoVars;
  "icos.stiltcluster": NoVars;

  // dependency-only / tool roles (referenced from meta deps and includes)
  "icos.borg": NoVars;
  "icos.iptables": NoVars;
  "icos.just": NoVars;
  "icos.restic": NoVars;
  "icos.sysstat": NoVars;
  "icos.uv": NoVars;

  // monitoring / exporters
  "icos.vmagent": NoVars;
  "icos.node_exporter": NoVars;
  "icos.script_exporter": { sexp_exporters: string[] };
}
