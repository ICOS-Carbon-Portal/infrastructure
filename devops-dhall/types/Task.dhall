-- Shared Ansible task type, auto-generated from all role task/handler files.
-- Covers 1554 task items across 115 unique fields. Every field is
-- Optional so any single task uses only the keys it needs (`Task::{ ... }`).
-- 15 polymorphic fields are union types (e.g. `loop`, `file`); construct with
-- `Task.Poly_<field>.<Tag> value`. dhall-to-yaml renders the payload transparently.
--
-- Usage from a role task file:
--   let Task = ../../../types/Task.dhall
--   in [ Task::{ name = Some "Install", apt = Some { ... } } ]

let Poly_ansible_builtin_shell = < Record : { cmd : Text } | Str : Text >

let Poly_become = < Bool : Bool | Str : Text >

let Poly_changed_when = < Bool : Bool | Str : Text | Texts : List Text >

let Poly_debug = < Record : { msg : Text } | Str : Text >

let Poly_failed_when = < Bool : Bool | Str : Text | Texts : List Text >

let Poly_file = < Record : { path : Optional Text, state : Optional Text, owner : Optional Text, group : Optional Text, name : Optional Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, src : Optional Text } | Str : Text >

let Poly_import_role = < Record : { name : Text, tasks_from : Optional Text } | Str : Text >

let Poly_include_role = < Record : { apply : Optional ({ tags : Text }), name : Text, tasks_from : Optional Text, public : Optional Bool } | Str : Text >

let Poly_include_tasks = < Record : { file : Text, apply : Optional ({ tags : Text }) } | Str : Text >

let Poly_local_action = < Record : { module : Text, ssh_config_file : Optional Text, hostname : Optional Text, remote_user : Optional Text, host : Optional Text, port : Optional Text, state : Text, name : Optional Text } | Str : Text >

let Poly_loop = < Records : List ({ question : Optional Text, value : Optional Text, vtype : Optional Text, s : Optional Text, f : Optional Text, param : Optional Text, append : Optional Bool, line : Optional Text, regex : Optional Text, src : Optional Text, dest : Optional Text, name : Optional Text, mode : Optional Text, key : Optional Text, val : Optional Text, file : Optional Text, set_fact : Optional Text, file_var : Optional Text, content : Optional Text, port : Optional Text, path : Optional Text }) | Str : Text | Texts : List Text >

let Poly_pip = < Record : { name : List Text, virtualenv : Optional Text, state : Optional Text } | Str : Text >

let Poly_service = < Record : { name : Text, state : Text, enabled : Optional Bool } | Str : Text >

let Poly_set_fact = < Record : { certbot_nginx_conf : Optional Text, destjarfile : Optional Text, name : Optional Text, nebula_resolve_type : Optional Text, cacheable : Optional Bool, nebula_ssh_public : Optional Text, quince_tomcat_dir : Optional Text, sshlogin_src_user : Optional Text, sshlogin_dst_user : Optional Text, _wg_is_installed : Optional Natural } | Str : Text >

let Poly_with_items = < Records : List ({ src : Text, dest : Text }) | Texts : List Text >

in  { Type =
  {
    always : Optional (List ({ name : Text, file : Optional ({ name : Optional Text, state : Text, path : Optional Text }), changed_when : Optional Bool, when : Optional Text, meta : Optional Text }))
  , `ansible.builtin.apt_key` : Optional ({ keyserver : Text, id : Text })
  , `ansible.builtin.copy` : Optional ({ dest : Text, mode : Text, content : Text })
  , `ansible.builtin.debconf` : Optional ({ name : Text, question : Text, value : Text, vtype : Text })
  , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
  , `ansible.builtin.group` : Optional ({ name : Text })
  , `ansible.builtin.package` : Optional ({ name : Text, state : Text })
  , `ansible.builtin.script` : Optional ({ cmd : Text, executable : Text })
  , `ansible.builtin.shell` : Optional Poly_ansible_builtin_shell
  , `ansible.posix.synchronize` : Optional ({ mode : Optional Text, copy_links : Optional Bool, src : Text, dest : Text, rsync_opts : Optional (List Text), owner : Optional Bool, group : Optional Bool, perms : Optional Bool, delete : Optional Bool })
  , apt : Optional ({ name : Optional (List Text), state : Optional Text, update_cache : Optional Bool, upgrade : Optional Text, deb : Optional Text, purge : Optional Bool, autoclean : Optional Bool, autoremove : Optional Bool, cache_valid_time : Optional Text, install_recommends : Optional Bool })
  , apt_key : Optional ({ id : Optional Text, url : Text, state : Text })
  , apt_repository : Optional ({ filename : Optional Text, repo : Text })
  , args : Optional ({ chdir : Optional Text, creates : Optional Text, executable : Optional Text, removes : Optional Text })
  , `assert` : Optional ({ that : List Text, quiet : Optional Bool })
  , authorized_key : Optional ({ user : Text, key : Text, state : Optional Text, exclusive : Optional Bool, key_options : Optional Text })
  , become : Optional Poly_become
  , become_user : Optional Text
  , block : Optional (List ({ name : Optional Text, file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text }), mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text }), postgresql_user : Optional ({ db : Text, name : Text, password : Text }), loop : Optional (List Text), postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text }), check_mode : Optional Bool, shellfact : Optional ({ exec : Text, fact : Text }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural }), command : Optional Text, register : Optional Text, changed_when : Optional Text, failed_when : Optional (List Text), github_release : Optional ({ user : Text, repo : Text, action : Text }), set_fact : Optional ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text }), args : Optional ({ chdir : Text }), notify : Optional Text, import_tasks : Optional Text, uri : Optional ({ url : Text, user : Optional Text, password : Optional Text }), systemd : Optional ({ name : Text, state : Optional Text }), copy : Optional ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural }), docker_image : Optional ({ source : Text, name : Text, build : { path : Text } }), apt : Optional ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural }), when : Optional Text, shell : Optional Text, known_hosts : Optional ({ path : Text, name : Text, key : Text }), import_role : Optional ({ name : Text, tasks_from : Text }), template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) }), slurp : Optional ({ src : Text }), delegate_to : Optional Text, expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }), iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }), iptables_raw : Optional ({ name : Text, rules : Text }), debug : Optional ({ msg : Text }), tags : Optional Text, `community.postgresql.postgresql_set` : Optional ({ name : Text, value : Text }), user : Optional ({ name : Text, home : Optional Text, state : Optional Text }), run_once : Optional Bool, fetch : Optional ({ src : Text, dest : Text, flat : Bool }), get_url : Optional ({ url : Text, dest : Text }), `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text }), fail : Optional ({ msg : Text }), `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text }), `ansible.builtin.shell` : Optional Text, retries : Optional Natural }))
  , blockinfile : Optional ({ path : Text, create : Optional Bool, marker : Text, block : Optional Text, insertafter : Optional Text, insertbefore : Optional Text, state : Optional Text })
  , changed_when : Optional Poly_changed_when
  , check_mode : Optional Bool
  , command : Optional Text
  , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Optional Text, pull : Optional Text, services : Optional (List Text), build : Optional Text })
  , `community.docker.docker_container_exec` : Optional ({ container : Text, command : Text, chdir : Text })
  , `community.docker.docker_image` : Optional ({ name : Text, source : Text })
  , `community.general.docker_container` : Optional ({ name : Text, image : Text, state : Text, recreate : Bool, shm_size : Optional Text, env : { POSTGRES_USER : Text, POSTGRES_PASSWORD : Text, POSTGRES_DB : Text }, published_ports : List Text, volumes : List Text, restart_policy : Text })
  , `community.general.docker_login` : Optional ({ registry_url : Text, username : Text, password : Text })
  , `community.general.pipx` : Optional ({ name : Text, executable : Text, python : Optional Text, editable : Optional Bool, force : Optional Text })
  , `community.general.snap` : Optional ({ name : Text, classic : Bool })
  , `community.general.sudoers` : Optional ({ name : Text, state : Text, user : Text, commands : Text })
  , copy : Optional ({ dest : Text, mode : Optional Text, content : Optional Text, src : Optional Text, backup : Optional Bool, owner : Optional Text, group : Optional Text, force : Optional Text, validate : Optional Text })
  , cron : Optional ({ user : Optional Text, job : Optional Text, hour : Optional Text, minute : Optional Text, name : Text, state : Optional Text, special_time : Optional Text })
  , debug : Optional Poly_debug
  , delay : Optional Natural
  , delegate_facts : Optional Bool
  , delegate_to : Optional Text
  , diff : Optional Bool
  , docker_compose : Optional ({ project_src : Text, build : Optional Bool, restarted : Optional Text, state : Optional Text })
  , docker_image : Optional ({ name : Text, source : Text })
  , docker_network : Optional ({ name : Text })
  , dpkg_selections : Optional ({ name : Text, selection : Text })
  , environment : Optional ({ BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK : Optional Text, BORG_RELOCATED_REPO_ACCESS_IS_OK : Optional Text, PIPX_BIN_DIR : Optional Text, GOPATH : Optional Text })
  , expect : Optional ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } })
  , fail : Optional ({ msg : Text })
  , failed_when : Optional Poly_failed_when
  , fetch : Optional ({ src : Text, dest : Text, flat : Optional Bool })
  , file : Optional Poly_file
  , filesystem : Optional ({ dev : Text, fstype : Text, opts : Text })
  , find : Optional ({ paths : Text, patterns : Text, excludes : Optional Text, file_type : Optional Text, recurse : Optional Bool })
  , get_url : Optional ({ url : Text, dest : Text, force : Optional Text, mode : Optional Text })
  , getent : Optional ({ database : Text, key : Text })
  , git : Optional ({ repo : Text, version : Optional Text, dest : Text, force : Optional Bool, update : Optional Text, key_file : Optional Text })
  , github_release : Optional ({ user : Text, repo : Text, action : Text })
  , group_by : Optional ({ key : Text })
  , htpasswd : Optional ({ path : Text, name : Text, password : Text, crypt_scheme : Optional Text, state : Optional Text })
  , icos_docker_compose : Optional ({ chdir : Text, force_recreate : Text })
  , import_role : Optional Poly_import_role
  , import_tasks : Optional Text
  , include_role : Optional Poly_include_role
  , include_tasks : Optional Poly_include_tasks
  , include_vars : Optional Text
  , iptables_raw : Optional ({ name : Text, rules : Optional Text, table : Optional Text, state : Optional Text, weight : Optional Natural })
  , known_hosts : Optional ({ name : Text, key : Text })
  , lineinfile : Optional ({ path : Text, regex : Optional Text, line : Optional Text, state : Optional Text, backrefs : Optional Bool, regexp : Optional Text, create : Optional Bool, owner : Optional Text, group : Optional Text, insertafter : Optional Text, mode : Optional Natural, insertbefore : Optional Text })
  , local_action : Optional Poly_local_action
  , locale_gen : Optional ({ name : Text, state : Text })
  , loop : Optional Poly_loop
  , loop_control : Optional ({ loop_var : Optional Text, label : Optional Text })
  , lxd_container : Optional ({ name : Text, state : Text, profiles : Optional (List Text), source : Optional ({ type : Text, mode : Text, server : Text, protocol : Text, alias : Text }), devices : Optional ({ root : { path : Text, type : Text, pool : Text, size : Text }, docker : Optional ({ path : Text, source : Text, type : Text, `raw.mount.options` : Text }), flexextract : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), data : Optional ({ path : Text, source : Text, type : Text, recursive : Text }), fluxcom : Optional ({ path : Text, source : Text, type : Text }), fluxcom_eo : Optional ({ path : Text, source : Text, type : Text }), stilt : Optional ({ path : Text, source : Text, type : Text }), eurocom : Optional ({ path : Text, source : Text, type : Text }), eurocom_web_root : Optional ({ path : Text, source : Text, type : Text }), filedrop : Optional ({ path : Text, source : Text, type : Text }), datademo : Optional ({ path : Text, source : Text, type : Text }), radonmap : Optional ({ path : Text, source : Text, type : Text }), dataAppStorage : Optional ({ path : Text, source : Text, readonly : Text, type : Text }), `1_docker` : Optional ({ path : Text, pool : Text, source : Text, type : Text }), `2_flexextract` : Optional ({ path : Text, source : Text, type : Text, recursive : Text }), `3_flexextract_meteo` : Optional ({ path : Text, source : Text, type : Text }), `4_output` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `5_meteo` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `6_ct2018` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `7_vprm` : Optional ({ path : Text, source : Text, readonly : Text, type : Text }), `8_stiltweb` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `9_cupcake` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), molefractions : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), ct2018 : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), cams : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), registry : Optional ({ path : Text, source : Text, type : Text }) }), wait_for_ipv4_addresses : Optional Bool, timeout : Optional Natural, config : Optional ({ `security.nesting` : Optional Text, `limits.cpu` : Optional Text, `limits.memory` : Text, `limits.memory.enforce` : Optional Text }), wait_for_ipv4_interfaces : Optional Text })
  , lxd_profile : Optional ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
  , lxd_static_ip : Optional ({ name : Text })
  , lxd_static_ip_info : Optional ({ name : Text })
  , make : Optional ({ chdir : Text, target : Text, params : Optional ({ BUILDTAGS : Text }) })
  , meta : Optional Text
  , mount : Optional ({ fstype : Text, state : Text, path : Text, src : Text, opts : Optional Text })
  , mysql_db : Optional ({ name : Text, state : Text, login_unix_socket : Text })
  , mysql_user : Optional ({ name : Text, password : Text, priv : Text, state : Text, login_unix_socket : Text })
  , name : Optional Text
  , notify : Optional (List Text)
  , openssh_keypair : Optional ({ path : Text, owner : Text, group : Text })
  , pip : Optional Poly_pip
  , postconf : Optional ({ param : Text, value : Text, reload : Optional Text, append : Optional Text, separator : Optional Text })
  , postgresql_db : Optional ({ name : Text, login_user : Text, login_password : Text, login_host : Text, login_port : Text, maintenance_db : Text })
  , postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
  , postgresql_user : Optional ({ db : Optional Text, name : Text, password : Text, login_user : Optional Text, login_password : Optional Text, login_host : Optional Text, login_port : Optional Text, login_unix_socket : Optional Text })
  , reboot : Optional ({ reboot_timeout : Natural })
  , register : Optional Text
  , replace : Optional ({ path : Text, regexp : Text, replace : Text })
  , rescue : Optional (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), when : Optional Text, fail : Optional ({ msg : Text }), file : Optional ({ path : Text, state : Text }), changed_when : Optional Bool }))
  , retries : Optional Natural
  , run_once : Optional Bool
  , service : Optional Poly_service
  , set_fact : Optional Poly_set_fact
  , shell : Optional Text
  , shellfact : Optional ({ exec : Text, fact : Text, bool : Optional Bool, list : Optional Bool })
  , slurp : Optional ({ src : Text })
  , slurpfact : Optional ({ path : Text, fact : Text })
  , stat : Optional ({ path : Text })
  , synchronize : Optional ({ src : Text, dest : Text })
  , sysctl : Optional ({ name : Text, value : Text })
  , systemd : Optional ({ name : Optional Text, state : Optional Text, daemon_reload : Optional Bool, enabled : Optional Text, `daemon-reload` : Optional Text, status : Optional Text })
  , tags : Optional (List Text)
  , template : Optional ({ src : Text, dest : Text, mode : Optional Text, variable_start_string : Optional Text, variable_end_string : Optional Text, lstrip_blocks : Optional Bool, validate : Optional Text, backup : Optional Bool, owner : Optional Text, group : Optional Text })
  , timezone : Optional ({ name : Text })
  , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool, owner : Optional Text, group : Optional Text, include : Optional (List Text), list_files : Optional Bool, extra_opts : Optional (List Text), mode : Optional Text, creates : Optional Text })
  , until : Optional Text
  , uri : Optional ({ url : Text, return_content : Optional Bool, method : Optional Text, user : Optional Text, password : Optional Text })
  , user : Optional ({ name : Text, uid : Optional Text, group : Optional Text, password : Optional Text, non_unique : Optional Bool, create_home : Optional Text, shell : Optional Text, home : Optional Text, password_lock : Optional Bool, groups : Optional (List Text), append : Optional Text, state : Optional Text, system : Optional Bool, generate_ssh_key : Optional Bool, remove : Optional Text })
  , vars : Optional ({ postgresql_backup_host : Optional Text, postgresql_backup_location : Optional Text, container_name : Optional Text, postgresql_user : Optional Text, postgresql_container_name : Optional Text, restheart_backup_host : Optional Text, fsd_name : Optional Text, fsd_target : Optional Text, zfsdocker_name : Optional Text, zfsdocker_size : Optional Text, nginxsite_name : Optional Text, filedrop_domain : Optional Text, filedrop_host : Optional Text, jupyter_domain : Optional Text, jupyter_ip : Optional Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_file : Optional Text, exploredata_name : Optional Text, exploredata_port : Optional Natural, exploredata_host : Optional Text, exploredata_domains : Optional (List Text), sshlogin_dst : Optional Text, sshlogin_src_user : Optional Text, sshlogin_dst_user : Optional Text, sshlogin_src_dst_host : Optional Text, sshlogin_src_dst_port : Optional Text, postgresql_postgis_enable : Optional Bool, postgresql_postgres_password : Optional Text, postgresql_listen_addresses : Optional Text, postgresql_pg_stat_enable : Optional Bool, postgresql_backup_script : Optional Text, postgis_bbclient_name : Optional Text, quince_name : Optional Text, quince_domains : Optional (List Text), timer_home : Optional Text, timer_exec : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_envs : Optional (List Text), timer_content : Optional Text, timer_user : Optional Text, block : Optional Text, marker : Optional Text, where : Optional Text, state : Optional Text, bbclient_name : Optional Text, bbclient_user : Optional Text, bbclient_home : Optional Text, bbclient_timer_conf : Optional Text, bbclient_timer_content : Optional Text, _restart_needed : Optional Text, fail2ban_config_files : Optional (List ({ dest : Text, content : Text })), nginxauth_file : Optional Text, nginxauth_users : Optional Text, jarservice_name : Optional Text, jarservice_home : Optional Text, jarservice_local : Optional Text, jarservice_unit : Optional Text, nginxsite_domains : Optional (List Text), jupyter_cert_name : Optional Text, conf : Optional Text, lxd_forward_port : Optional Text, file : Optional Text, keys : Optional Text, set_fact : Optional Text, file_var : Optional Text, python_util_src : Optional Text, nginxauth_name : Optional Text, dbin_download_dest : Optional Text, dbin_user : Optional Text, dbin_repo : Optional Text, dbin_path : Optional Text, dbin_arch : Optional Text, timer_wdir : Optional Text, vmagent_config_dest : Optional Text, vmagent_config_content : Optional Text, dbin_src : Optional Text, dbin_url : Optional Text, _builtin_version : Optional Text, nginxauth_conf : Optional Text, nginxsite_users : Optional (List Text), dbin_unar : Optional Bool, timer_state : Optional Text, timer_config : Optional Text, timer_service : Optional Text })
  , wait_for : Optional ({ host : Text, port : Text, delay : Natural, timeout : Natural })
  , when : Optional (List Text)
  , with_fileglob : Optional (List Text)
  , with_items : Optional Poly_with_items
  , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : Optional ({ mountpoint : Optional Text, quota : Optional Text, refquota : Optional Text, volsize : Optional Text }) })
  }
, default =
  {
    always = None (List ({ name : Text, file : Optional ({ name : Optional Text, state : Text, path : Optional Text }), changed_when : Optional Bool, when : Optional Text, meta : Optional Text }))
  , `ansible.builtin.apt_key` = None ({ keyserver : Text, id : Text })
  , `ansible.builtin.copy` = None ({ dest : Text, mode : Text, content : Text })
  , `ansible.builtin.debconf` = None ({ name : Text, question : Text, value : Text, vtype : Text })
  , `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
  , `ansible.builtin.group` = None ({ name : Text })
  , `ansible.builtin.package` = None ({ name : Text, state : Text })
  , `ansible.builtin.script` = None ({ cmd : Text, executable : Text })
  , `ansible.builtin.shell` = None Poly_ansible_builtin_shell
  , `ansible.posix.synchronize` = None ({ mode : Optional Text, copy_links : Optional Bool, src : Text, dest : Text, rsync_opts : Optional (List Text), owner : Optional Bool, group : Optional Bool, perms : Optional Bool, delete : Optional Bool })
  , apt = None ({ name : Optional (List Text), state : Optional Text, update_cache : Optional Bool, upgrade : Optional Text, deb : Optional Text, purge : Optional Bool, autoclean : Optional Bool, autoremove : Optional Bool, cache_valid_time : Optional Text, install_recommends : Optional Bool })
  , apt_key = None ({ id : Optional Text, url : Text, state : Text })
  , apt_repository = None ({ filename : Optional Text, repo : Text })
  , args = None ({ chdir : Optional Text, creates : Optional Text, executable : Optional Text, removes : Optional Text })
  , `assert` = None ({ that : List Text, quiet : Optional Bool })
  , authorized_key = None ({ user : Text, key : Text, state : Optional Text, exclusive : Optional Bool, key_options : Optional Text })
  , become = None Poly_become
  , become_user = None Text
  , block = None (List ({ name : Optional Text, file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text }), mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text }), postgresql_user : Optional ({ db : Text, name : Text, password : Text }), loop : Optional (List Text), postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text }), check_mode : Optional Bool, shellfact : Optional ({ exec : Text, fact : Text }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural }), command : Optional Text, register : Optional Text, changed_when : Optional Text, failed_when : Optional (List Text), github_release : Optional ({ user : Text, repo : Text, action : Text }), set_fact : Optional ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text }), args : Optional ({ chdir : Text }), notify : Optional Text, import_tasks : Optional Text, uri : Optional ({ url : Text, user : Optional Text, password : Optional Text }), systemd : Optional ({ name : Text, state : Optional Text }), copy : Optional ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural }), docker_image : Optional ({ source : Text, name : Text, build : { path : Text } }), apt : Optional ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural }), when : Optional Text, shell : Optional Text, known_hosts : Optional ({ path : Text, name : Text, key : Text }), import_role : Optional ({ name : Text, tasks_from : Text }), template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) }), slurp : Optional ({ src : Text }), delegate_to : Optional Text, expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }), iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }), iptables_raw : Optional ({ name : Text, rules : Text }), debug : Optional ({ msg : Text }), tags : Optional Text, `community.postgresql.postgresql_set` : Optional ({ name : Text, value : Text }), user : Optional ({ name : Text, home : Optional Text, state : Optional Text }), run_once : Optional Bool, fetch : Optional ({ src : Text, dest : Text, flat : Bool }), get_url : Optional ({ url : Text, dest : Text }), `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text }), fail : Optional ({ msg : Text }), `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text }), `ansible.builtin.shell` : Optional Text, retries : Optional Natural }))
  , blockinfile = None ({ path : Text, create : Optional Bool, marker : Text, block : Optional Text, insertafter : Optional Text, insertbefore : Optional Text, state : Optional Text })
  , changed_when = None Poly_changed_when
  , check_mode = None Bool
  , command = None Text
  , `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Optional Text, pull : Optional Text, services : Optional (List Text), build : Optional Text })
  , `community.docker.docker_container_exec` = None ({ container : Text, command : Text, chdir : Text })
  , `community.docker.docker_image` = None ({ name : Text, source : Text })
  , `community.general.docker_container` = None ({ name : Text, image : Text, state : Text, recreate : Bool, shm_size : Optional Text, env : { POSTGRES_USER : Text, POSTGRES_PASSWORD : Text, POSTGRES_DB : Text }, published_ports : List Text, volumes : List Text, restart_policy : Text })
  , `community.general.docker_login` = None ({ registry_url : Text, username : Text, password : Text })
  , `community.general.pipx` = None ({ name : Text, executable : Text, python : Optional Text, editable : Optional Bool, force : Optional Text })
  , `community.general.snap` = None ({ name : Text, classic : Bool })
  , `community.general.sudoers` = None ({ name : Text, state : Text, user : Text, commands : Text })
  , copy = None ({ dest : Text, mode : Optional Text, content : Optional Text, src : Optional Text, backup : Optional Bool, owner : Optional Text, group : Optional Text, force : Optional Text, validate : Optional Text })
  , cron = None ({ user : Optional Text, job : Optional Text, hour : Optional Text, minute : Optional Text, name : Text, state : Optional Text, special_time : Optional Text })
  , debug = None Poly_debug
  , delay = None Natural
  , delegate_facts = None Bool
  , delegate_to = None Text
  , diff = None Bool
  , docker_compose = None ({ project_src : Text, build : Optional Bool, restarted : Optional Text, state : Optional Text })
  , docker_image = None ({ name : Text, source : Text })
  , docker_network = None ({ name : Text })
  , dpkg_selections = None ({ name : Text, selection : Text })
  , environment = None ({ BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK : Optional Text, BORG_RELOCATED_REPO_ACCESS_IS_OK : Optional Text, PIPX_BIN_DIR : Optional Text, GOPATH : Optional Text })
  , expect = None ({ command : Text, responses : { `password:` : Text, `sftp>` : List Text } })
  , fail = None ({ msg : Text })
  , failed_when = None Poly_failed_when
  , fetch = None ({ src : Text, dest : Text, flat : Optional Bool })
  , file = None Poly_file
  , filesystem = None ({ dev : Text, fstype : Text, opts : Text })
  , find = None ({ paths : Text, patterns : Text, excludes : Optional Text, file_type : Optional Text, recurse : Optional Bool })
  , get_url = None ({ url : Text, dest : Text, force : Optional Text, mode : Optional Text })
  , getent = None ({ database : Text, key : Text })
  , git = None ({ repo : Text, version : Optional Text, dest : Text, force : Optional Bool, update : Optional Text, key_file : Optional Text })
  , github_release = None ({ user : Text, repo : Text, action : Text })
  , group_by = None ({ key : Text })
  , htpasswd = None ({ path : Text, name : Text, password : Text, crypt_scheme : Optional Text, state : Optional Text })
  , icos_docker_compose = None ({ chdir : Text, force_recreate : Text })
  , import_role = None Poly_import_role
  , import_tasks = None Text
  , include_role = None Poly_include_role
  , include_tasks = None Poly_include_tasks
  , include_vars = None Text
  , iptables_raw = None ({ name : Text, rules : Optional Text, table : Optional Text, state : Optional Text, weight : Optional Natural })
  , known_hosts = None ({ name : Text, key : Text })
  , lineinfile = None ({ path : Text, regex : Optional Text, line : Optional Text, state : Optional Text, backrefs : Optional Bool, regexp : Optional Text, create : Optional Bool, owner : Optional Text, group : Optional Text, insertafter : Optional Text, mode : Optional Natural, insertbefore : Optional Text })
  , local_action = None Poly_local_action
  , locale_gen = None ({ name : Text, state : Text })
  , loop = None Poly_loop
  , loop_control = None ({ loop_var : Optional Text, label : Optional Text })
  , lxd_container = None ({ name : Text, state : Text, profiles : Optional (List Text), source : Optional ({ type : Text, mode : Text, server : Text, protocol : Text, alias : Text }), devices : Optional ({ root : { path : Text, type : Text, pool : Text, size : Text }, docker : Optional ({ path : Text, source : Text, type : Text, `raw.mount.options` : Text }), flexextract : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), data : Optional ({ path : Text, source : Text, type : Text, recursive : Text }), fluxcom : Optional ({ path : Text, source : Text, type : Text }), fluxcom_eo : Optional ({ path : Text, source : Text, type : Text }), stilt : Optional ({ path : Text, source : Text, type : Text }), eurocom : Optional ({ path : Text, source : Text, type : Text }), eurocom_web_root : Optional ({ path : Text, source : Text, type : Text }), filedrop : Optional ({ path : Text, source : Text, type : Text }), datademo : Optional ({ path : Text, source : Text, type : Text }), radonmap : Optional ({ path : Text, source : Text, type : Text }), dataAppStorage : Optional ({ path : Text, source : Text, readonly : Text, type : Text }), `1_docker` : Optional ({ path : Text, pool : Text, source : Text, type : Text }), `2_flexextract` : Optional ({ path : Text, source : Text, type : Text, recursive : Text }), `3_flexextract_meteo` : Optional ({ path : Text, source : Text, type : Text }), `4_output` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `5_meteo` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `6_ct2018` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `7_vprm` : Optional ({ path : Text, source : Text, readonly : Text, type : Text }), `8_stiltweb` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `9_cupcake` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), molefractions : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), ct2018 : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), cams : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), registry : Optional ({ path : Text, source : Text, type : Text }) }), wait_for_ipv4_addresses : Optional Bool, timeout : Optional Natural, config : Optional ({ `security.nesting` : Optional Text, `limits.cpu` : Optional Text, `limits.memory` : Text, `limits.memory.enforce` : Optional Text }), wait_for_ipv4_interfaces : Optional Text })
  , lxd_profile = None ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
  , lxd_static_ip = None ({ name : Text })
  , lxd_static_ip_info = None ({ name : Text })
  , make = None ({ chdir : Text, target : Text, params : Optional ({ BUILDTAGS : Text }) })
  , meta = None Text
  , mount = None ({ fstype : Text, state : Text, path : Text, src : Text, opts : Optional Text })
  , mysql_db = None ({ name : Text, state : Text, login_unix_socket : Text })
  , mysql_user = None ({ name : Text, password : Text, priv : Text, state : Text, login_unix_socket : Text })
  , name = None Text
  , notify = None (List Text)
  , openssh_keypair = None ({ path : Text, owner : Text, group : Text })
  , pip = None Poly_pip
  , postconf = None ({ param : Text, value : Text, reload : Optional Text, append : Optional Text, separator : Optional Text })
  , postgresql_db = None ({ name : Text, login_user : Text, login_password : Text, login_host : Text, login_port : Text, maintenance_db : Text })
  , postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
  , postgresql_user = None ({ db : Optional Text, name : Text, password : Text, login_user : Optional Text, login_password : Optional Text, login_host : Optional Text, login_port : Optional Text, login_unix_socket : Optional Text })
  , reboot = None ({ reboot_timeout : Natural })
  , register = None Text
  , replace = None ({ path : Text, regexp : Text, replace : Text })
  , rescue = None (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), when : Optional Text, fail : Optional ({ msg : Text }), file : Optional ({ path : Text, state : Text }), changed_when : Optional Bool }))
  , retries = None Natural
  , run_once = None Bool
  , service = None Poly_service
  , set_fact = None Poly_set_fact
  , shell = None Text
  , shellfact = None ({ exec : Text, fact : Text, bool : Optional Bool, list : Optional Bool })
  , slurp = None ({ src : Text })
  , slurpfact = None ({ path : Text, fact : Text })
  , stat = None ({ path : Text })
  , synchronize = None ({ src : Text, dest : Text })
  , sysctl = None ({ name : Text, value : Text })
  , systemd = None ({ name : Optional Text, state : Optional Text, daemon_reload : Optional Bool, enabled : Optional Text, `daemon-reload` : Optional Text, status : Optional Text })
  , tags = None (List Text)
  , template = None ({ src : Text, dest : Text, mode : Optional Text, variable_start_string : Optional Text, variable_end_string : Optional Text, lstrip_blocks : Optional Bool, validate : Optional Text, backup : Optional Bool, owner : Optional Text, group : Optional Text })
  , timezone = None ({ name : Text })
  , unarchive = None ({ src : Text, dest : Text, remote_src : Bool, owner : Optional Text, group : Optional Text, include : Optional (List Text), list_files : Optional Bool, extra_opts : Optional (List Text), mode : Optional Text, creates : Optional Text })
  , until = None Text
  , uri = None ({ url : Text, return_content : Optional Bool, method : Optional Text, user : Optional Text, password : Optional Text })
  , user = None ({ name : Text, uid : Optional Text, group : Optional Text, password : Optional Text, non_unique : Optional Bool, create_home : Optional Text, shell : Optional Text, home : Optional Text, password_lock : Optional Bool, groups : Optional (List Text), append : Optional Text, state : Optional Text, system : Optional Bool, generate_ssh_key : Optional Bool, remove : Optional Text })
  , vars = None ({ postgresql_backup_host : Optional Text, postgresql_backup_location : Optional Text, container_name : Optional Text, postgresql_user : Optional Text, postgresql_container_name : Optional Text, restheart_backup_host : Optional Text, fsd_name : Optional Text, fsd_target : Optional Text, zfsdocker_name : Optional Text, zfsdocker_size : Optional Text, nginxsite_name : Optional Text, filedrop_domain : Optional Text, filedrop_host : Optional Text, jupyter_domain : Optional Text, jupyter_ip : Optional Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_file : Optional Text, exploredata_name : Optional Text, exploredata_port : Optional Natural, exploredata_host : Optional Text, exploredata_domains : Optional (List Text), sshlogin_dst : Optional Text, sshlogin_src_user : Optional Text, sshlogin_dst_user : Optional Text, sshlogin_src_dst_host : Optional Text, sshlogin_src_dst_port : Optional Text, postgresql_postgis_enable : Optional Bool, postgresql_postgres_password : Optional Text, postgresql_listen_addresses : Optional Text, postgresql_pg_stat_enable : Optional Bool, postgresql_backup_script : Optional Text, postgis_bbclient_name : Optional Text, quince_name : Optional Text, quince_domains : Optional (List Text), timer_home : Optional Text, timer_exec : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_envs : Optional (List Text), timer_content : Optional Text, timer_user : Optional Text, block : Optional Text, marker : Optional Text, where : Optional Text, state : Optional Text, bbclient_name : Optional Text, bbclient_user : Optional Text, bbclient_home : Optional Text, bbclient_timer_conf : Optional Text, bbclient_timer_content : Optional Text, _restart_needed : Optional Text, fail2ban_config_files : Optional (List ({ dest : Text, content : Text })), nginxauth_file : Optional Text, nginxauth_users : Optional Text, jarservice_name : Optional Text, jarservice_home : Optional Text, jarservice_local : Optional Text, jarservice_unit : Optional Text, nginxsite_domains : Optional (List Text), jupyter_cert_name : Optional Text, conf : Optional Text, lxd_forward_port : Optional Text, file : Optional Text, keys : Optional Text, set_fact : Optional Text, file_var : Optional Text, python_util_src : Optional Text, nginxauth_name : Optional Text, dbin_download_dest : Optional Text, dbin_user : Optional Text, dbin_repo : Optional Text, dbin_path : Optional Text, dbin_arch : Optional Text, timer_wdir : Optional Text, vmagent_config_dest : Optional Text, vmagent_config_content : Optional Text, dbin_src : Optional Text, dbin_url : Optional Text, _builtin_version : Optional Text, nginxauth_conf : Optional Text, nginxsite_users : Optional (List Text), dbin_unar : Optional Bool, timer_state : Optional Text, timer_config : Optional Text, timer_service : Optional Text })
  , wait_for = None ({ host : Text, port : Text, delay : Natural, timeout : Natural })
  , when = None (List Text)
  , with_fileglob = None (List Text)
  , with_items = None Poly_with_items
  , zfs = None ({ name : Text, state : Text, extra_zfs_properties : Optional ({ mountpoint : Optional Text, quota : Optional Text, refquota : Optional Text, volsize : Optional Text }) })
  }
, Poly_ansible_builtin_shell = Poly_ansible_builtin_shell
, Poly_become = Poly_become
, Poly_changed_when = Poly_changed_when
, Poly_debug = Poly_debug
, Poly_failed_when = Poly_failed_when
, Poly_file = Poly_file
, Poly_import_role = Poly_import_role
, Poly_include_role = Poly_include_role
, Poly_include_tasks = Poly_include_tasks
, Poly_local_action = Poly_local_action
, Poly_loop = Poly_loop
, Poly_pip = Poly_pip
, Poly_service = Poly_service
, Poly_set_fact = Poly_set_fact
, Poly_with_items = Poly_with_items
}
