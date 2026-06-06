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
// `Tmpl` (= string | Template) documents that a value may be a plain string or
// a Jinja template like tmpl`${V.nexus_home}/bbclient`.
import type { VarValue } from "./ansible/values.ts";
import type { Tmpl } from "./template.ts";

// A role ref may carry a `vars:` block (a sibling of `role:`) and/or a display
// `name:`; both are allowed on any role in addition to its own variables.
type Common = { name?: Tmpl; vars?: Record<string, VarValue> };

// A disk device passed to icos.lxd_vm (`recursive`/`readonly` are LXC's stringy
// "true"/"false"). Keyed by device name.
type LxdDevice = {
  path: Tmpl;
  source: Tmpl;
  type: Tmpl;
  recursive?: Tmpl;
  readonly?: Tmpl;
};

type NoVars = Record<PropertyKey, never>;

export interface Roles {
  "icos.keycloak": { kc_hostname: Tmpl };
  "icos.matomo": NoVars;
  "icos.geoip": NoVars;
  "icos.nexus": NoVars;

  // Used across many playbooks with different subsets of vars, so all optional.
  "icos.bbclient2": Common & {
    bbclient_name?: Tmpl;
    bbclient_user?: Tmpl;
    bbclient_home?: Tmpl;
    bbclient_coldbackup?: Tmpl;
    bbclient_coldbackup_hour?: number;
    bbclient_coldbackup_minute?: number;
    bbclient_remotes?: Tmpl[];
    bbclient_timer_content?: Tmpl;
    bbclient_patterns?: Tmpl;
  };

  "icos.certbot2": {
    certbot_name?: Tmpl;
    certbot_domains?: Tmpl | Tmpl[];
  };

  "icos.cpauth": NoVars;

  "icos.postfix": {
    postfix_config_list: { param: Tmpl; value: Tmpl }[];
  };
  "icos.dovecot": { dovecot_domains: Tmpl[] };
  "icos.opendkim": {
    opendkim_domains: Tmpl[];
    opendkim_domains_testkeys?: Tmpl[];
  };

  // core.yml
  "icos.postgis": NoVars;
  "icos.restheart": NoVars;
  "icos.cpmeta": Common & {
    cpmeta_filestorage_target?: Tmpl;
    cpmeta_jar_file?: Tmpl;
    cpmeta_config_files?: Tmpl[];
  };
  "icos.cpdata": { cpdata_netcdf_folder?: Tmpl };
  "icos.doi": NoVars;
  "icos.virtuoso": NoVars;
  "icos.nginxsite": Common & {
    nginxsite_name?: Tmpl;
    nginxsite_file?: Tmpl;
    nginxsite_users?: { username: Tmpl; password: Tmpl }[];
    registry_host?: Tmpl;
    registry_cert?: Tmpl;
    registry_allow?: Tmpl;
    dokku_proxy_host?: Tmpl;
    dokku_proxy_port?: number;
    jupyter_domain?: Tmpl;
    jupyter_cert_name?: Tmpl;
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
  "icos.telegraf": { telegraf_conf: Tmpl };
  "icos.mailman": NoVars;
  "icos.exploredata": NoVars;
  "icos.rspamd": NoVars;
  "icos.dokku": NoVars;
  "icos.flexpart": { flexpart_install_run?: boolean };
  "icos.flexextract": {
    flexextract_src_dir: Tmpl;
    flexextract_download_host: Tmpl;
  };
  "icos.eurocom": {
    eurocom_users: Tmpl;
    eurocom_web_root: Tmpl;
    eurocom_data_home: Tmpl;
  };
  "icos.filedrop": { filedrop_data_home: Tmpl };
  "icos.nextcloud": {
    nextcloud_admin_password: Tmpl;
    nextcloud_domain: Tmpl;
    nextcloud_exporter_pass: Tmpl;
    nextcloud_volumes: Tmpl[];
  };
  "icos.onlyoffice": { onlyoffice_domain: Tmpl; onlyoffice_secret: Tmpl };
  "icos.registry": { registry_users: Tmpl };
  "icos.victoriametrics": {
    vm_graf_domain: Tmpl;
    vm_graf_pass: Tmpl;
    vm_promlens_token: Tmpl;
  };
  "icos.jbuild": {
    jbuild_users: Tmpl;
    jbuild_registry_pass: Tmpl;
    jbuild_edctl_host: Tmpl;
    jbuild_edctl_host_name: Tmpl;
    jbuild_edctl_host_port: number;
    jbuild_rsync_host: Tmpl;
    jbuild_rsync_host_port: number;
    jbuild_rsync_host_name: Tmpl;
    jbuild_jyctl_host: Tmpl;
    jbuild_jyctl_host_port: number;
    jbuild_jyctl_host_name: Tmpl;
  };
  "icos.jupyter": Common & {
    jupyter_admins?: Tmpl | null;
    jupyter_user_volumes?: Tmpl;
    jupyter_backup_enable?: boolean;
    jupyter_jusers_enable?: boolean;
    jupyter_hub_config?: {
      admin_users?: Tmpl | Tmpl[];
      mem_limit?: Tmpl;
      cpu_limit?: number;
    };
    bbclient_name?: Tmpl;
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
  "icos.caddy": { caddy_name?: Tmpl; caddy_conf?: Tmpl };
  "icos.bbserver": NoVars;
  "icos.mosh": NoVars;
  "icos.pve_server": NoVars;
  "icos.users": NoVars;
  "icos.rdflog": Common & {
    rdflog_postgres_version?: number;
    rdflog_rep_pass?: Tmpl;
    rdflog_restore_file?: Tmpl;
  };
  "icos.pgrep": NoVars;
  "icos.fail2ban": {
    fail2ban_config_files: { dest: Tmpl; content: Tmpl }[];
  };
  "icos.dnsmasq": { dnsmasq_interface: Tmpl; dnsmasq_config: Tmpl };
  "icos.rsyncd": {
    rsyncd_enable: boolean;
    rsyncd_users: { name: Tmpl }[];
    rsyncd_conf: Tmpl;
  };
  "icos.superuser": {
    superuser_disable_coredump?: boolean;
    superuser_list: { name: Tmpl; key: Tmpl }[];
  };
  "ops.zfs": NoVars;

  // lxd / vm provisioning
  "icos.lxd_vm": Common & {
    lxd_vm_name?: Tmpl;
    lxd_vm_docker?: boolean;
    lxd_vm_docker_size?: Tmpl;
    lxd_vm_root_size?: Tmpl;
    lxd_vm_root_pool?: Tmpl;
    lxd_vm_ubuntu_version?: Tmpl;
    lxd_vm_config?: Record<string, Tmpl>;
    lxd_vm_devices?: Record<string, LxdDevice>;
    lxd_vm_profiles?: Tmpl[];
  };
  "icos.lxd_guest": { user_conf?: Tmpl; user_disable_coredump?: boolean };
  "icos.lxd_forward": { lxd_forward_ip: Tmpl; lxd_forward_name: Tmpl };
  "icos.nginxforward": {
    nginxforward_name: Tmpl;
    nginxforward_host: Tmpl;
    nginxforward_port: number;
    nginxforward_cert: Tmpl;
    nginxforward_domains: Tmpl[];
  };
  "icos.sshlogin": {
    sshlogin_dst?: Tmpl;
    sshlogin_src_user: Tmpl;
    sshlogin_dst_user: Tmpl;
    sshlogin_src_dst_name?: Tmpl;
  };
  "icos.sftp_user": {
    sftp_user_dir: Tmpl;
    sftp_user_login: Tmpl;
    sftp_user_password: Tmpl;
    sftp_user_owner?: Tmpl;
    sftp_user_hostdesc?: Tmpl;
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

  // roles referenced only via import_tasks/include_role (no role() call site)
  "icos.cni_plugins": NoVars;
  "icos.conmon": NoVars;
  "icos.docker_utils": NoVars;
  "icos.github_download_bin": NoVars;
  "icos.golang": NoVars;
  "icos.jarservice2": NoVars;
  "icos.nginxauth": NoVars;
  "icos.postgresql": NoVars;
  "icos.python_util": NoVars;
  "icos.quince": NoVars;
  "icos.timer": NoVars;
  "icos.timer2": NoVars;
  "icos.zfsdocker": NoVars;

  // monitoring / exporters
  "icos.vmagent": NoVars;
  "icos.node_exporter": NoVars;
  "icos.script_exporter": { sexp_exporters: Tmpl[] };
}
