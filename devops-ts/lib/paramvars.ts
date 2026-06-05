// Names-only registry of role caller-parameters and play-, include- and
// task-level variables: names a playbook or play supplies (role vars,
// include_tasks vars, task `vars:` blocks, `-e` extra vars) and tasks read,
// that no defaults/vars file defines — so gen-contexts.ts cannot discover
// them and they are hand-curated here. Ansible variable names form a single
// flat namespace, so declaring a name makes it a checked `V.x` everywhere.
// Names only: the V accessor maps every key to a Ref, so the uniform
// `string` type is never consulted.
//
// The check at the bottom forces every parameter declared in a lib/roles.ts
// schema to appear in some registry, so a role param is always referenceable
// as a checked `V.x` from the role's own task files.
import type { Roles } from "./roles.ts";
import type { Vars } from "./vars.ts";
import type { Globals } from "./globals.ts";
import type { BuiltinVars } from "./builtins.ts";
import type { AllVars } from "./allvars.ts";
import type { VaultVars } from "./vaultvars.ts";
import type { VarShapes } from "./shapes.ts";

export interface ParamVars {
  _ssh_user: string;
  _version: string;
  admin_users: string;
  amalthea_ip: string;
  bbclient_coldbackup: string;
  bbclient_key_data: string;
  bbclient_remote: string;
  bbclient_remote_keys: string;
  bbclient_remotes: string;
  bbclient_timer_content: string;
  block: string;
  caddy_conf: string;
  caddy_name: string;
  callisto_ip: string;
  configfile: string;
  conmon_local_version: string;
  cpauth_jar_file: string;
  cpdata_jar_file: string;
  cpdata_netcdf_folder: string;
  cpmeta_jar_file: string;
  cpu_limit: string;
  data_fast_path: string;
  data_path: string;
  db_name: string;
  dbin_path: string;
  dbin_repo: string;
  dbin_unar: string;
  dbin_url: string;
  dbin_user: string;
  deb_arch: string;
  destjarfile: string;
  dnsmasq_config: string;
  dnsmasq_instance: string;
  dnsmasq_interface: string;
  docker_compose_home: string;
  docker_path: string;
  doi_jar_file: string;
  dokku_proxy_host: string;
  dokku_proxy_port: string;
  dokku_redirect_domains: string;
  dokku_static_domains: string;
  dovecot_domains: string;
  eurocom_users: string;
  exploredata_ip: string;
  exploredata_type: string;
  fake_architecture: string;
  fdp_jar_file: string;
  file: string;
  file_var: string;
  filedrop_data_home: string;
  filedrop_domain: string;
  filedrop_jar_file: string;
  flexextract_src_dir: string;
  flexpart_install_run: string;
  flexpart_ssh_remote_host: string;
  flexpart_ssh_remote_ip: string;
  flexpart_ssh_users: string;
  fsd_name: string;
  ganymede_domains: string;
  fsd_path: string;
  fsd_target: string;
  geoip_docker_build: string;
  git_version: string;
  golang_local_version: string;
  grafana_datasource_version: string;
  groupfolder_name: string;
  host_uid: string;
  icosdata_bind_mounts: string;
  icosdata_mkdirs: string;
  jarfile: string;
  jarservice_check: string;
  jarservice_githash: string;
  jarservice_home: string;
  jarservice_local: string;
  jarservice_name: string;
  jarservice_state: string;
  jarservice_unit: string;
  jbuild_edctl_host: string;
  jbuild_force: string;
  jbuild_jyctl_host: string;
  jbuild_registry_pass: string;
  jbuild_rsync_host: string;
  jbuild_users: string;
  jupyter_admins: string;
  jupyter_backup_enable: string;
  jupyter_cert_name: string;
  jupyter_domain: string;
  jupyter_domains: string;
  jupyter_ip: string;
  jupyter_user_volumes: string;
  kc_hostname: string;
  keys: string;
  lazydocker_arch: string;
  local_cert_dir: string;
  local_conf_dir: string;
  local_tmp: string;
  lockuser: string;
  lxd_forward_ip: string;
  lxd_forward_name: string;
  lxd_vm_name: string;
  mailman_domains: string;
  mailman_rest_pass: string;
  marker: string;
  mem_limit: string;
  nebula_cert_files: string;
  nebula_ip: string;
  nebula_passphrase: string;
  new_name: string;
  nextcloud_admin_password: string;
  nextcloud_exporter_pass: string;
  nginxforward_cert: string;
  nginxforward_domains: string;
  nginxforward_name: string;
  nginxforward_port: string;
  nginxforward_users: string;
  node_exporter_scripts: string;
  old_name: string;
  onlyoffice_domain: string;
  onlyoffice_secret: string;
  opendkim_domains: string;
  pool_name: string;
  pool_path: string;
  postgis_cplog_users: string;
  postgresql_backup_host: string;
  postgresql_backup_location: string;
  postgresql_container_name: string;
  postgresql_hba_file: string;
  postgresql_version: string;
  python_util_src: string;
  quince_domains: string;
  quince_name: string;
  quince_tomcat_dir: string;
  rdflog_restore_file: string;
  rdflog_vm_name: string;
  registry_allow: string;
  registry_cert: string;
  registry_host: string;
  registry_users: string;
  remove_keys: string;
  restheart_backup_host: string;
  rspamd_admin_password: string;
  rspamd_domain: string;
  rsyncd_conf: string;
  rsyncd_users: string;
  servicename: string;
  servicetemplate: string;
  set_fact: string;
  sexp_block: string;
  sexp_config: string;
  sexp_exporters: string;
  sexp_marker: string;
  sexp_state: string;
  sftp_authorized_keys: string;
  sftp_dirs: string;
  sftp_exec: string;
  sftp_user: string;
  sftp_user_dir: string;
  sftp_user_login: string;
  ssh_port: string;
  sshlogin_dst: string;
  sshlogin_dst_home: string;
  sshlogin_dst_user: string;
  sshlogin_src_home: string;
  sshlogin_src_ip: string;
  sshlogin_src_user: string;
  sshlogin_user: string;
  state: string;
  stilt_input_dir: string;
  stiltcluster_jar_file: string;
  stiltweb_jar_file: string;
  superuser_disable_coredump: string;
  superuser_list: string;
  telegraf_conf: string;
  timer_config: string;
  timer_content: string;
  timer_name: string;
  timer_service: string;
  user_disable_coredump: string;
  username: string;
  vm_graf_domain: string;
  vm_graf_pass: string;
  vm_promlens_token: string;
  vmagent_config_content: string;
  vmagent_config_dest: string;
  website: string;
  where: string;
  virtualenv_recreate: string;
  nexus_certbot_enable: string;
  jarservice_conf_only: string;
  lxd_vm_variant: string;
  _restart_needed: string;
  nebula_ssh_public: string;
  nginxconfig: string;
  lxd_is_snap: string;
  flexextract_docker_build: string;
  stiltcluster_fetch_host: string;
  wordpress_domains: string;
  zrepl_config: string;
}

// --- completeness check ------------------------------------------------------
// Every name declared in a Roles schema (lib/roles.ts), excluding the Common
// envelope keys and index-signature maps, must be declared in a registry. An
// error on `_ok` below means a roles.ts param was added without registering
// its name — add it to ParamVars above.
type RoleParamNames = {
  [R in keyof Roles]: string extends keyof Roles[R] ? never
    : Exclude<keyof Roles[R] & string, "name" | "vars">;
}[keyof Roles];
type MissingRoleParams = Exclude<
  RoleParamNames,
  | keyof ParamVars
  | keyof Vars
  | keyof Globals
  | keyof BuiltinVars
  | keyof AllVars
  | keyof VaultVars
  | keyof VarShapes
>;
type AssertNever<T extends never> = T;
export type _ParamVarsComplete = AssertNever<MissingRoleParams>;
