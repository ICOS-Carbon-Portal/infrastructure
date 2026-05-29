-- Shared Ansible task type, auto-generated from all role task/handler files.
-- Covers 1397 task items across 106 unique fields. Every field is
-- Optional so any single task uses only the keys it needs (`Task::{ ... }`).
--
-- Usage from a role task file:
--   let Task = ../../../types/Task.dhall
--   in [ Task::{ name = Some "Install", apt = Some { ... } } ]

{ Type =
  {
    always : Optional (List ({ name : Text, file : Optional ({ name : Optional Text, state : Text, path : Optional Text }), changed_when : Optional Bool, when : Optional Text, meta : Optional Text }))
  , `ansible.builtin.copy` : Optional ({ dest : Text, mode : Text, content : Text })
  , `ansible.builtin.debconf` : Optional ({ name : Text, question : Text, value : Text, vtype : Text })
  , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
  , `ansible.builtin.package` : Optional ({ name : Text, state : Text })
  , `ansible.builtin.script` : Optional ({ cmd : Text, executable : Text })
  , `ansible.builtin.shell` : Optional Text
  , `ansible.posix.synchronize` : Optional ({ src : Text, dest : Text, owner : Bool, group : Bool, rsync_opts : Optional (List Text), delete : Optional Bool })
  , apt : Optional ({ name : Optional (List Text), state : Optional Text, update_cache : Optional Bool, deb : Optional Text, purge : Optional Bool, upgrade : Optional Bool, autoclean : Optional Bool, autoremove : Optional Bool, cache_valid_time : Optional Text, install_recommends : Optional Bool })
  , apt_key : Optional ({ id : Optional Text, url : Text, state : Text })
  , apt_repository : Optional ({ filename : Optional Text, repo : Text })
  , args : Optional ({ creates : Optional Text, chdir : Optional Text, executable : Optional Text, removes : Optional Text })
  , `assert` : Optional ({ that : List Text, quiet : Optional Bool })
  , authorized_key : Optional ({ user : Text, key_options : Optional Text, key : Text, state : Optional Text, exclusive : Optional Bool })
  , become : Optional Text
  , become_user : Optional Text
  , block : Optional (List ({ name : Optional Text, check_mode : Optional Bool, shellfact : Optional ({ exec : Text, fact : Text }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural }), command : Optional Text, register : Optional Text, changed_when : Optional Text, failed_when : Optional (List Text), github_release : Optional ({ user : Text, repo : Text, action : Text }), set_fact : Optional ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text }), args : Optional ({ chdir : Text }), notify : Optional Text, import_tasks : Optional Text, uri : Optional ({ url : Text, user : Optional Text, password : Optional Text }), systemd : Optional ({ name : Text, state : Optional Text }), copy : Optional ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural }), file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text }), loop : Optional (List Text), docker_image : Optional ({ source : Text, name : Text, build : { path : Text } }), apt : Optional ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural }), when : Optional Text, shell : Optional Text, known_hosts : Optional ({ path : Text, name : Text, key : Text }), import_role : Optional ({ name : Text, tasks_from : Text }), template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) }), slurp : Optional ({ src : Text }), delegate_to : Optional Text, expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }), iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }), iptables_raw : Optional ({ name : Text, rules : Text }), debug : Optional ({ msg : Text }), tags : Optional Text, `community.postgresql.postgresql_set` : Optional ({ name : Text, value : Text }), user : Optional ({ name : Text, home : Optional Text, state : Optional Text }), run_once : Optional Bool, fetch : Optional ({ src : Text, dest : Text, flat : Bool }), get_url : Optional ({ url : Text, dest : Text }), `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text }), fail : Optional ({ msg : Text }), `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text }), `ansible.builtin.shell` : Optional Text, retries : Optional Natural }))
  , blockinfile : Optional ({ marker : Text, state : Optional Text, create : Optional Bool, insertafter : Optional Text, path : Text, block : Optional Text, insertbefore : Optional Text })
  , changed_when : Optional Text
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
  , copy : Optional ({ src : Optional Text, dest : Text, mode : Optional Text, content : Optional Text, backup : Optional Bool, owner : Optional Text, group : Optional Text, force : Optional Text, validate : Optional Text })
  , cron : Optional ({ user : Optional Text, job : Optional Text, hour : Optional Text, minute : Optional Text, name : Text, state : Optional Text, special_time : Optional Text })
  , debug : Optional ({ msg : Text })
  , delay : Optional Natural
  , delegate_facts : Optional Bool
  , delegate_to : Optional Text
  , diff : Optional Bool
  , docker_compose : Optional ({ project_src : Text, build : Optional Bool, restarted : Optional Text, state : Optional Text })
  , docker_image : Optional ({ name : Text, source : Text })
  , docker_network : Optional ({ name : Text })
  , dpkg_selections : Optional ({ name : Text, selection : Text })
  , environment : Optional ({ BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK : Optional Text, BORG_RELOCATED_REPO_ACCESS_IS_OK : Optional Text, PIPX_BIN_DIR : Optional Text, GOPATH : Optional Text })
  , fail : Optional ({ msg : Text })
  , failed_when : Optional Text
  , fetch : Optional ({ src : Text, dest : Text, flat : Bool })
  , file : Optional ({ path : Optional Text, state : Optional Text, mode : Optional Text, owner : Optional Text, group : Optional Text, name : Optional Text, dest : Optional Text, recurse : Optional Bool, src : Optional Text })
  , filesystem : Optional ({ dev : Text, fstype : Text, opts : Text })
  , find : Optional ({ paths : Text, patterns : Text, excludes : Optional Text, file_type : Optional Text, recurse : Optional Bool })
  , get_url : Optional ({ url : Text, dest : Text, force : Optional Text, mode : Optional Text })
  , git : Optional ({ repo : Text, version : Optional Text, dest : Text, force : Optional Bool, update : Optional Text, key_file : Optional Text })
  , github_release : Optional ({ user : Text, repo : Text, action : Text })
  , htpasswd : Optional ({ path : Text, name : Text, password : Text, crypt_scheme : Optional Text, state : Optional Text })
  , icos_docker_compose : Optional ({ chdir : Text, force_recreate : Text })
  , import_role : Optional ({ name : Text })
  , import_tasks : Optional Text
  , include_role : Optional ({ name : Text, apply : Optional ({ tags : Text }), public : Optional Bool, tasks_from : Optional Text })
  , include_tasks : Optional Text
  , include_vars : Optional Text
  , iptables_raw : Optional ({ name : Text, rules : Optional Text, weight : Optional Natural, table : Optional Text, state : Optional Text })
  , known_hosts : Optional ({ name : Text, key : Text })
  , lineinfile : Optional ({ path : Text, line : Optional Text, state : Optional Text, regex : Optional Text, regexp : Optional Text, create : Optional Bool, owner : Optional Text, group : Optional Text, insertafter : Optional Text, mode : Optional Natural, insertbefore : Optional Text })
  , local_action : Optional ({ module : Text, ssh_config_file : Optional Text, hostname : Optional Text, remote_user : Optional Text, host : Optional Text, port : Optional Text, state : Text, name : Optional Text })
  , locale_gen : Optional ({ name : Text, state : Text })
  , loop : Optional (List Text)
  , loop_control : Optional ({ loop_var : Optional Text, label : Optional Text })
  , lxd_container : Optional ({ name : Text, state : Text, profiles : Optional Text, source : Optional Text, config : Optional Text, devices : Optional Text, wait_for_ipv4_addresses : Optional Bool, wait_for_ipv4_interfaces : Optional Text, timeout : Optional Natural })
  , lxd_static_ip : Optional ({ name : Text })
  , lxd_static_ip_info : Optional ({ name : Text })
  , make : Optional ({ chdir : Text, target : Text, params : Optional ({ BUILDTAGS : Text }) })
  , meta : Optional Text
  , mysql_db : Optional ({ name : Text, state : Text, login_unix_socket : Text })
  , mysql_user : Optional ({ name : Text, password : Text, priv : Text, state : Text, login_unix_socket : Text })
  , name : Optional Text
  , notify : Optional (List Text)
  , openssh_keypair : Optional ({ path : Text, owner : Text, group : Text })
  , pip : Optional ({ name : List Text, virtualenv : Optional Text, state : Optional Text })
  , postconf : Optional ({ param : Text, value : Text, append : Text, reload : Optional Text, separator : Optional Text })
  , postgresql_db : Optional ({ name : Text, login_user : Text, login_password : Text, login_host : Text, login_port : Text, maintenance_db : Text })
  , postgresql_user : Optional ({ db : Optional Text, name : Text, password : Text, login_user : Optional Text, login_password : Optional Text, login_host : Optional Text, login_port : Optional Text, login_unix_socket : Optional Text })
  , reboot : Optional ({ reboot_timeout : Natural })
  , register : Optional Text
  , rescue : Optional (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), when : Optional Text, fail : Optional ({ msg : Text }), file : Optional ({ path : Text, state : Text }), changed_when : Optional Bool }))
  , retries : Optional Natural
  , run_once : Optional Bool
  , service : Optional ({ name : Text, state : Text, enabled : Optional Bool })
  , set_fact : Optional ({ certbot_nginx_conf : Optional Text, destjarfile : Optional Text, name : Optional Text, nebula_resolve_type : Optional Text, cacheable : Optional Bool, nebula_ssh_public : Optional Text, quince_tomcat_dir : Optional Text, sshlogin_src_user : Optional Text, sshlogin_dst_user : Optional Text, _wg_is_installed : Optional Natural })
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
  , user : Optional ({ name : Text, home : Optional Text, create_home : Optional Text, shell : Optional Text, groups : Optional (List Text), append : Optional Text, state : Optional Text, system : Optional Bool, password : Optional Text, generate_ssh_key : Optional Bool, remove : Optional Text })
  , vars : Optional ({ timer_home : Optional Text, timer_exec : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_envs : Optional (List Text), timer_content : Optional Text, timer_user : Optional Text, block : Optional Text, marker : Optional Text, where : Optional Text, state : Optional Text, bbclient_name : Optional Text, bbclient_user : Optional Text, bbclient_home : Optional Text, bbclient_timer_conf : Optional Text, bbclient_timer_content : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_name : Optional Text, nginxsite_file : Optional Text, _restart_needed : Optional Text, fail2ban_config_files : Optional (List ({ dest : Text, content : Text })), nginxauth_file : Optional Text, nginxauth_users : Optional Text, jarservice_name : Optional Text, jarservice_home : Optional Text, jarservice_local : Optional Text, jarservice_unit : Optional Text, nginxsite_domains : Optional (List Text), jupyter_cert_name : Optional Text, conf : Optional Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, lxd_forward_port : Optional Text, file : Optional Text, keys : Optional Text, zfsdocker_size : Optional Text, set_fact : Optional Text, file_var : Optional Text, python_util_src : Optional Text, nginxauth_name : Optional Text, dbin_download_dest : Optional Text, dbin_user : Optional Text, dbin_repo : Optional Text, dbin_path : Optional Text, dbin_arch : Optional Text, timer_wdir : Optional Text, vmagent_config_dest : Optional Text, vmagent_config_content : Optional Text, dbin_src : Optional Text, dbin_url : Optional Text, _builtin_version : Optional Text, nginxauth_conf : Optional Text, nginxsite_users : Optional (List Text), dbin_unar : Optional Bool, timer_state : Optional Text, timer_config : Optional Text, timer_service : Optional Text })
  , wait_for : Optional ({ host : Text, port : Text, delay : Natural, timeout : Natural })
  , when : Optional (List Text)
  , with_fileglob : Optional (List Text)
  , with_items : Optional (List Text)
  , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : Optional ({ volsize : Text }) })
  }
, default =
  {
    always = None (List ({ name : Text, file : Optional ({ name : Optional Text, state : Text, path : Optional Text }), changed_when : Optional Bool, when : Optional Text, meta : Optional Text }))
  , `ansible.builtin.copy` = None ({ dest : Text, mode : Text, content : Text })
  , `ansible.builtin.debconf` = None ({ name : Text, question : Text, value : Text, vtype : Text })
  , `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
  , `ansible.builtin.package` = None ({ name : Text, state : Text })
  , `ansible.builtin.script` = None ({ cmd : Text, executable : Text })
  , `ansible.builtin.shell` = None Text
  , `ansible.posix.synchronize` = None ({ src : Text, dest : Text, owner : Bool, group : Bool, rsync_opts : Optional (List Text), delete : Optional Bool })
  , apt = None ({ name : Optional (List Text), state : Optional Text, update_cache : Optional Bool, deb : Optional Text, purge : Optional Bool, upgrade : Optional Bool, autoclean : Optional Bool, autoremove : Optional Bool, cache_valid_time : Optional Text, install_recommends : Optional Bool })
  , apt_key = None ({ id : Optional Text, url : Text, state : Text })
  , apt_repository = None ({ filename : Optional Text, repo : Text })
  , args = None ({ creates : Optional Text, chdir : Optional Text, executable : Optional Text, removes : Optional Text })
  , `assert` = None ({ that : List Text, quiet : Optional Bool })
  , authorized_key = None ({ user : Text, key_options : Optional Text, key : Text, state : Optional Text, exclusive : Optional Bool })
  , become = None Text
  , become_user = None Text
  , block = None (List ({ name : Optional Text, check_mode : Optional Bool, shellfact : Optional ({ exec : Text, fact : Text }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural }), command : Optional Text, register : Optional Text, changed_when : Optional Text, failed_when : Optional (List Text), github_release : Optional ({ user : Text, repo : Text, action : Text }), set_fact : Optional ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text }), args : Optional ({ chdir : Text }), notify : Optional Text, import_tasks : Optional Text, uri : Optional ({ url : Text, user : Optional Text, password : Optional Text }), systemd : Optional ({ name : Text, state : Optional Text }), copy : Optional ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural }), file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text }), loop : Optional (List Text), docker_image : Optional ({ source : Text, name : Text, build : { path : Text } }), apt : Optional ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural }), when : Optional Text, shell : Optional Text, known_hosts : Optional ({ path : Text, name : Text, key : Text }), import_role : Optional ({ name : Text, tasks_from : Text }), template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text }), `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text }), include_role : Optional ({ name : Text }), vars : Optional ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) }), slurp : Optional ({ src : Text }), delegate_to : Optional Text, expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } }), iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }), iptables_raw : Optional ({ name : Text, rules : Text }), debug : Optional ({ msg : Text }), tags : Optional Text, `community.postgresql.postgresql_set` : Optional ({ name : Text, value : Text }), user : Optional ({ name : Text, home : Optional Text, state : Optional Text }), run_once : Optional Bool, fetch : Optional ({ src : Text, dest : Text, flat : Bool }), get_url : Optional ({ url : Text, dest : Text }), `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text }), fail : Optional ({ msg : Text }), `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text }), `ansible.builtin.shell` : Optional Text, retries : Optional Natural }))
  , blockinfile = None ({ marker : Text, state : Optional Text, create : Optional Bool, insertafter : Optional Text, path : Text, block : Optional Text, insertbefore : Optional Text })
  , changed_when = None Text
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
  , copy = None ({ src : Optional Text, dest : Text, mode : Optional Text, content : Optional Text, backup : Optional Bool, owner : Optional Text, group : Optional Text, force : Optional Text, validate : Optional Text })
  , cron = None ({ user : Optional Text, job : Optional Text, hour : Optional Text, minute : Optional Text, name : Text, state : Optional Text, special_time : Optional Text })
  , debug = None ({ msg : Text })
  , delay = None Natural
  , delegate_facts = None Bool
  , delegate_to = None Text
  , diff = None Bool
  , docker_compose = None ({ project_src : Text, build : Optional Bool, restarted : Optional Text, state : Optional Text })
  , docker_image = None ({ name : Text, source : Text })
  , docker_network = None ({ name : Text })
  , dpkg_selections = None ({ name : Text, selection : Text })
  , environment = None ({ BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK : Optional Text, BORG_RELOCATED_REPO_ACCESS_IS_OK : Optional Text, PIPX_BIN_DIR : Optional Text, GOPATH : Optional Text })
  , fail = None ({ msg : Text })
  , failed_when = None Text
  , fetch = None ({ src : Text, dest : Text, flat : Bool })
  , file = None ({ path : Optional Text, state : Optional Text, mode : Optional Text, owner : Optional Text, group : Optional Text, name : Optional Text, dest : Optional Text, recurse : Optional Bool, src : Optional Text })
  , filesystem = None ({ dev : Text, fstype : Text, opts : Text })
  , find = None ({ paths : Text, patterns : Text, excludes : Optional Text, file_type : Optional Text, recurse : Optional Bool })
  , get_url = None ({ url : Text, dest : Text, force : Optional Text, mode : Optional Text })
  , git = None ({ repo : Text, version : Optional Text, dest : Text, force : Optional Bool, update : Optional Text, key_file : Optional Text })
  , github_release = None ({ user : Text, repo : Text, action : Text })
  , htpasswd = None ({ path : Text, name : Text, password : Text, crypt_scheme : Optional Text, state : Optional Text })
  , icos_docker_compose = None ({ chdir : Text, force_recreate : Text })
  , import_role = None ({ name : Text })
  , import_tasks = None Text
  , include_role = None ({ name : Text, apply : Optional ({ tags : Text }), public : Optional Bool, tasks_from : Optional Text })
  , include_tasks = None Text
  , include_vars = None Text
  , iptables_raw = None ({ name : Text, rules : Optional Text, weight : Optional Natural, table : Optional Text, state : Optional Text })
  , known_hosts = None ({ name : Text, key : Text })
  , lineinfile = None ({ path : Text, line : Optional Text, state : Optional Text, regex : Optional Text, regexp : Optional Text, create : Optional Bool, owner : Optional Text, group : Optional Text, insertafter : Optional Text, mode : Optional Natural, insertbefore : Optional Text })
  , local_action = None ({ module : Text, ssh_config_file : Optional Text, hostname : Optional Text, remote_user : Optional Text, host : Optional Text, port : Optional Text, state : Text, name : Optional Text })
  , locale_gen = None ({ name : Text, state : Text })
  , loop = None (List Text)
  , loop_control = None ({ loop_var : Optional Text, label : Optional Text })
  , lxd_container = None ({ name : Text, state : Text, profiles : Optional Text, source : Optional Text, config : Optional Text, devices : Optional Text, wait_for_ipv4_addresses : Optional Bool, wait_for_ipv4_interfaces : Optional Text, timeout : Optional Natural })
  , lxd_static_ip = None ({ name : Text })
  , lxd_static_ip_info = None ({ name : Text })
  , make = None ({ chdir : Text, target : Text, params : Optional ({ BUILDTAGS : Text }) })
  , meta = None Text
  , mysql_db = None ({ name : Text, state : Text, login_unix_socket : Text })
  , mysql_user = None ({ name : Text, password : Text, priv : Text, state : Text, login_unix_socket : Text })
  , name = None Text
  , notify = None (List Text)
  , openssh_keypair = None ({ path : Text, owner : Text, group : Text })
  , pip = None ({ name : List Text, virtualenv : Optional Text, state : Optional Text })
  , postconf = None ({ param : Text, value : Text, append : Text, reload : Optional Text, separator : Optional Text })
  , postgresql_db = None ({ name : Text, login_user : Text, login_password : Text, login_host : Text, login_port : Text, maintenance_db : Text })
  , postgresql_user = None ({ db : Optional Text, name : Text, password : Text, login_user : Optional Text, login_password : Optional Text, login_host : Optional Text, login_port : Optional Text, login_unix_socket : Optional Text })
  , reboot = None ({ reboot_timeout : Natural })
  , register = None Text
  , rescue = None (List ({ name : Text, command : Optional Text, register : Optional Text, debug : Optional ({ msg : Text }), copy : Optional ({ remote_src : Bool, dest : Text, src : Text }), when : Optional Text, fail : Optional ({ msg : Text }), file : Optional ({ path : Text, state : Text }), changed_when : Optional Bool }))
  , retries = None Natural
  , run_once = None Bool
  , service = None ({ name : Text, state : Text, enabled : Optional Bool })
  , set_fact = None ({ certbot_nginx_conf : Optional Text, destjarfile : Optional Text, name : Optional Text, nebula_resolve_type : Optional Text, cacheable : Optional Bool, nebula_ssh_public : Optional Text, quince_tomcat_dir : Optional Text, sshlogin_src_user : Optional Text, sshlogin_dst_user : Optional Text, _wg_is_installed : Optional Natural })
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
  , user = None ({ name : Text, home : Optional Text, create_home : Optional Text, shell : Optional Text, groups : Optional (List Text), append : Optional Text, state : Optional Text, system : Optional Bool, password : Optional Text, generate_ssh_key : Optional Bool, remove : Optional Text })
  , vars = None ({ timer_home : Optional Text, timer_exec : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_envs : Optional (List Text), timer_content : Optional Text, timer_user : Optional Text, block : Optional Text, marker : Optional Text, where : Optional Text, state : Optional Text, bbclient_name : Optional Text, bbclient_user : Optional Text, bbclient_home : Optional Text, bbclient_timer_conf : Optional Text, bbclient_timer_content : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_name : Optional Text, nginxsite_file : Optional Text, _restart_needed : Optional Text, fail2ban_config_files : Optional (List ({ dest : Text, content : Text })), nginxauth_file : Optional Text, nginxauth_users : Optional Text, jarservice_name : Optional Text, jarservice_home : Optional Text, jarservice_local : Optional Text, jarservice_unit : Optional Text, nginxsite_domains : Optional (List Text), jupyter_cert_name : Optional Text, conf : Optional Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, lxd_forward_port : Optional Text, file : Optional Text, keys : Optional Text, zfsdocker_size : Optional Text, set_fact : Optional Text, file_var : Optional Text, python_util_src : Optional Text, nginxauth_name : Optional Text, dbin_download_dest : Optional Text, dbin_user : Optional Text, dbin_repo : Optional Text, dbin_path : Optional Text, dbin_arch : Optional Text, timer_wdir : Optional Text, vmagent_config_dest : Optional Text, vmagent_config_content : Optional Text, dbin_src : Optional Text, dbin_url : Optional Text, _builtin_version : Optional Text, nginxauth_conf : Optional Text, nginxsite_users : Optional (List Text), dbin_unar : Optional Bool, timer_state : Optional Text, timer_config : Optional Text, timer_service : Optional Text })
  , wait_for = None ({ host : Text, port : Text, delay : Natural, timeout : Natural })
  , when = None (List Text)
  , with_fileglob = None (List Text)
  , with_items = None (List Text)
  , zfs = None ({ name : Text, state : Text, extra_zfs_properties : Optional ({ volsize : Text }) })
  }
}
