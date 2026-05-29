-- Auto-generated from ../../../../devops/roles/icos.lxd_vm/tasks/remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some (Task.Poly_loop.Texts [ "lxd_vm_name" ])
    }
  , Task::{
      name = Some "Remove vm from local ssh config",
      local_action = Some (Task.Poly_local_action.Record {
          module = "community.general.ssh_config",
          ssh_config_file = Some "~{{ lookup('env', 'USER') }}/.ssh/config.icos",
          hostname = None Text,
          remote_user = None Text,
          host = Some "{{ lxd_vm_name }}",
          port = None Text,
          state = "absent",
          name = None Text
      })
    }
  , Task::{
      name = Some "Remove local known_host",
      local_action = Some (Task.Poly_local_action.Record {
          module = "known_hosts",
          ssh_config_file = None Text,
          hostname = None Text,
          remote_user = None Text,
          host = None Text,
          port = None Text,
          state = "absent",
          name = Some "[{{ inventory_hostname }}]:{{ lxd_vm_port }}"
      })
    }
  , Task::{
      name = Some "Remove ssh port forward and /etc/hosts entry",
      include_role = Some (Task.Poly_include_role.Record {
          apply = None (({ tags : Text })),
          name = "icos.lxd_forward",
          tasks_from = Some "remove.yml",
          public = None Bool
      }),
      vars = Some {
        postgresql_backup_host = None Text,
        postgresql_backup_location = None Text,
        container_name = None Text,
        postgresql_user = None Text,
        postgresql_container_name = None Text,
        restheart_backup_host = None Text,
        fsd_name = None Text,
        fsd_target = None Text,
        zfsdocker_name = None Text,
        zfsdocker_size = None Text,
        nginxsite_name = None Text,
        filedrop_domain = None Text,
        filedrop_host = None Text,
        jupyter_domain = None Text,
        jupyter_ip = None Text,
        lxd_forward_name = Some "{{ lxd_vm_name }}",
        lxd_forward_ip = None Text,
        certbot_name = None Text,
        certbot_domains = None ((List Text)),
        nginxsite_file = None Text,
        exploredata_name = None Text,
        exploredata_port = None Natural,
        exploredata_host = None Text,
        exploredata_domains = None ((List Text)),
        sshlogin_dst = None Text,
        sshlogin_src_user = None Text,
        sshlogin_dst_user = None Text,
        sshlogin_src_dst_host = None Text,
        sshlogin_src_dst_port = None Text,
        postgresql_postgis_enable = None Bool,
        postgresql_postgres_password = None Text,
        postgresql_listen_addresses = None Text,
        postgresql_pg_stat_enable = None Bool,
        postgresql_backup_script = None Text,
        postgis_bbclient_name = None Text,
        quince_name = None Text,
        quince_domains = None ((List Text)),
        timer_home = None Text,
        timer_exec = None Text,
        timer_name = None Text,
        timer_conf = None Text,
        timer_envs = None ((List Text)),
        timer_content = None Text,
        timer_user = None Text,
        block = None Text,
        marker = None Text,
        where = None Text,
        state = None Text,
        bbclient_name = None Text,
        bbclient_user = None Text,
        bbclient_home = None Text,
        bbclient_timer_conf = None Text,
        bbclient_timer_content = None Text,
        _restart_needed = None Text,
        fail2ban_config_files = None ((List ({ dest : Text, content : Text }))),
        nginxauth_file = None Text,
        nginxauth_users = None Text,
        jarservice_name = None Text,
        jarservice_home = None Text,
        jarservice_local = None Text,
        jarservice_unit = None Text,
        nginxsite_domains = None ((List Text)),
        jupyter_cert_name = None Text,
        conf = None Text,
        lxd_forward_port = None Text,
        file = None Text,
        keys = None Text,
        set_fact = None Text,
        file_var = None Text,
        python_util_src = None Text,
        nginxauth_name = None Text,
        dbin_download_dest = None Text,
        dbin_user = None Text,
        dbin_repo = None Text,
        dbin_path = None Text,
        dbin_arch = None Text,
        timer_wdir = None Text,
        vmagent_config_dest = None Text,
        vmagent_config_content = None Text,
        dbin_src = None Text,
        dbin_url = None Text,
        _builtin_version = None Text,
        nginxauth_conf = None Text,
        nginxsite_users = None ((List Text)),
        dbin_unar = None Bool,
        timer_state = None Text,
        timer_config = None Text,
        timer_service = None Text
    }
    }
  , Task::{
      name = Some "Remove lxd container",
      lxd_container = Some {
        name = "{{ lxd_vm_name }}",
        state = "absent",
        profiles = None ((List Text)),
        source = None (({ type : Text, mode : Text, server : Text, protocol : Text, alias : Text })),
        devices = None (({ root : { path : Text, type : Text, pool : Text, size : Text }, docker : Optional ({ path : Text, source : Text, type : Text, `raw.mount.options` : Text }), flexextract : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), data : Optional ({ path : Text, source : Text, type : Text, recursive : Text }), fluxcom : Optional ({ path : Text, source : Text, type : Text }), fluxcom_eo : Optional ({ path : Text, source : Text, type : Text }), stilt : Optional ({ path : Text, source : Text, type : Text }), eurocom : Optional ({ path : Text, source : Text, type : Text }), eurocom_web_root : Optional ({ path : Text, source : Text, type : Text }), filedrop : Optional ({ path : Text, source : Text, type : Text }), datademo : Optional ({ path : Text, source : Text, type : Text }), radonmap : Optional ({ path : Text, source : Text, type : Text }), dataAppStorage : Optional ({ path : Text, source : Text, readonly : Text, type : Text }), `1_docker` : Optional ({ path : Text, pool : Text, source : Text, type : Text }), `2_flexextract` : Optional ({ path : Text, source : Text, type : Text, recursive : Text }), `3_flexextract_meteo` : Optional ({ path : Text, source : Text, type : Text }), `4_output` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `5_meteo` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `6_ct2018` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `7_vprm` : Optional ({ path : Text, source : Text, readonly : Text, type : Text }), `8_stiltweb` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), `9_cupcake` : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), molefractions : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), ct2018 : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), cams : Optional ({ path : Text, source : Text, type : Text, readonly : Text }), registry : Optional ({ path : Text, source : Text, type : Text }) })),
        wait_for_ipv4_addresses = None Bool,
        timeout = None Natural,
        config = None (({ `security.nesting` : Optional Text, `limits.cpu` : Optional Text, `limits.memory` : Text, `limits.memory.enforce` : Optional Text })),
        wait_for_ipv4_interfaces = None Text
    }
    }
  , Task::{
      when = Some [ "lxd_vm_variant == 'ext4'" ],
      block = Some (let Task =
        { Type =
            { name : Optional Text
        , file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user : Optional ({ db : Text, name : Text, password : Text })
        , loop : Optional (List Text)
        , postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text })
        , check_mode : Optional Bool
        , shellfact : Optional ({ exec : Text, fact : Text })
        , authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text })
        , blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural })
        , command : Optional Text
        , register : Optional Text
        , changed_when : Optional Text
        , failed_when : Optional (List Text)
        , github_release : Optional ({ user : Text, repo : Text, action : Text })
        , set_fact : Optional ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text })
        , args : Optional ({ chdir : Text })
        , notify : Optional Text
        , import_tasks : Optional Text
        , uri : Optional ({ url : Text, user : Optional Text, password : Optional Text })
        , systemd : Optional ({ name : Text, state : Optional Text })
        , copy : Optional ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural })
        , docker_image : Optional ({ source : Text, name : Text, build : { path : Text } })
        , apt : Optional ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural })
        , when : Optional Text
        , shell : Optional Text
        , known_hosts : Optional ({ path : Text, name : Text, key : Text })
        , import_role : Optional ({ name : Text, tasks_from : Text })
        , template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text })
        , `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text })
        , include_role : Optional ({ name : Text })
        , vars : Optional ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) })
        , slurp : Optional ({ src : Text })
        , delegate_to : Optional Text
        , expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } })
        , iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text })
        , iptables_raw : Optional ({ name : Text, rules : Text })
        , debug : Optional ({ msg : Text })
        , tags : Optional Text
        , `community.postgresql.postgresql_set` : Optional ({ name : Text, value : Text })
        , user : Optional ({ name : Text, home : Optional Text, state : Optional Text })
        , run_once : Optional Bool
        , fetch : Optional ({ src : Text, dest : Text, flat : Bool })
        , get_url : Optional ({ url : Text, dest : Text })
        , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text })
        , fail : Optional ({ msg : Text })
        , `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text })
        , `ansible.builtin.shell` : Optional Text
        , retries : Optional Natural
      }
        , default =
            { name = None Text
        , file = None ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount = None ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user = None ({ db : Text, name : Text, password : Text })
        , loop = None (List Text)
        , postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` = None ({ name : Text, db : Text, schema : Text })
        , check_mode = None Bool
        , shellfact = None ({ exec : Text, fact : Text })
        , authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text })
        , blockinfile = None ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural })
        , command = None Text
        , register = None Text
        , changed_when = None Text
        , failed_when = None (List Text)
        , github_release = None ({ user : Text, repo : Text, action : Text })
        , set_fact = None ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text })
        , args = None ({ chdir : Text })
        , notify = None Text
        , import_tasks = None Text
        , uri = None ({ url : Text, user : Optional Text, password : Optional Text })
        , systemd = None ({ name : Text, state : Optional Text })
        , copy = None ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural })
        , docker_image = None ({ source : Text, name : Text, build : { path : Text } })
        , apt = None ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural })
        , when = None Text
        , shell = None Text
        , known_hosts = None ({ path : Text, name : Text, key : Text })
        , import_role = None ({ name : Text, tasks_from : Text })
        , template = None ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text })
        , `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text })
        , include_role = None ({ name : Text })
        , vars = None ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) })
        , slurp = None ({ src : Text })
        , delegate_to = None Text
        , expect = None ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } })
        , iptables = None ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text })
        , iptables_raw = None ({ name : Text, rules : Text })
        , debug = None ({ msg : Text })
        , tags = None Text
        , `community.postgresql.postgresql_set` = None ({ name : Text, value : Text })
        , user = None ({ name : Text, home : Optional Text, state : Optional Text })
        , run_once = None Bool
        , fetch = None ({ src : Text, dest : Text, flat : Bool })
        , get_url = None ({ url : Text, dest : Text })
        , `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text })
        , fail = None ({ msg : Text })
        , `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text })
        , `ansible.builtin.shell` = None Text
        , retries = None Natural
      }
        }

    in  [
        Task::{
          name = Some "Delete storage pool",
          register = Some "_r",
          changed_when = Some "_r.stdout.endswith('deleted')",
          shell = Some ''
          /snap/bin/lxc storage delete {{ lxd_vm_root_pool }} || :

        ''
        }
    ])
    }
  , Task::{
      when = Some [ "lxd_vm_variant == 'zfs'" ],
      block = Some (let Task =
        { Type =
            { name : Optional Text
        , file : Optional ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user : Optional ({ db : Text, name : Text, password : Text })
        , loop : Optional (List Text)
        , postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text })
        , check_mode : Optional Bool
        , shellfact : Optional ({ exec : Text, fact : Text })
        , authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text })
        , blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural })
        , command : Optional Text
        , register : Optional Text
        , changed_when : Optional Text
        , failed_when : Optional (List Text)
        , github_release : Optional ({ user : Text, repo : Text, action : Text })
        , set_fact : Optional ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text })
        , args : Optional ({ chdir : Text })
        , notify : Optional Text
        , import_tasks : Optional Text
        , uri : Optional ({ url : Text, user : Optional Text, password : Optional Text })
        , systemd : Optional ({ name : Text, state : Optional Text })
        , copy : Optional ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural })
        , docker_image : Optional ({ source : Text, name : Text, build : { path : Text } })
        , apt : Optional ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural })
        , when : Optional Text
        , shell : Optional Text
        , known_hosts : Optional ({ path : Text, name : Text, key : Text })
        , import_role : Optional ({ name : Text, tasks_from : Text })
        , template : Optional ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text })
        , `ansible.builtin.pip` : Optional ({ virtualenv : Text, virtualenv_command : Text, requirements : Text })
        , include_role : Optional ({ name : Text })
        , vars : Optional ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) })
        , slurp : Optional ({ src : Text })
        , delegate_to : Optional Text
        , expect : Optional ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } })
        , iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text })
        , iptables_raw : Optional ({ name : Text, rules : Text })
        , debug : Optional ({ msg : Text })
        , tags : Optional Text
        , `community.postgresql.postgresql_set` : Optional ({ name : Text, value : Text })
        , user : Optional ({ name : Text, home : Optional Text, state : Optional Text })
        , run_once : Optional Bool
        , fetch : Optional ({ src : Text, dest : Text, flat : Bool })
        , get_url : Optional ({ url : Text, dest : Text })
        , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text })
        , fail : Optional ({ msg : Text })
        , `ansible.builtin.template` : Optional ({ src : Text, dest : Text, owner : Optional Text })
        , `ansible.builtin.shell` : Optional Text
        , retries : Optional Natural
      }
        , default =
            { name = None Text
        , file = None ({ path : Optional Text, state : Text, mode : Optional Text, dest : Optional Text, recurse : Optional Bool, owner : Optional Text, modification_time : Optional Text, access_time : Optional Text })
        , mount = None ({ src : Text, path : Text, state : Text, fstype : Text })
        , postgresql_user = None ({ db : Text, name : Text, password : Text })
        , loop = None (List Text)
        , postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
        , `community.postgresql.postgresql_ext` = None ({ name : Text, db : Text, schema : Text })
        , check_mode = None Bool
        , shellfact = None ({ exec : Text, fact : Text })
        , authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text })
        , blockinfile = None ({ create : Bool, path : Text, marker : Text, block : Text, state : Optional Text, backup : Optional Bool, insertafter : Optional Text, insertbefore : Optional Text, mode : Optional Natural })
        , command = None Text
        , register = None Text
        , changed_when = None Text
        , failed_when = None (List Text)
        , github_release = None ({ user : Text, repo : Text, action : Text })
        , set_fact = None ({ borg_version : Optional Text, cacheable : Bool, dive_version : Optional Text, lazydocker_version : Optional Text, just_version : Optional Text, nebula_version : Optional Text, nebula_resolve_type : Optional Text, restic_version : Optional Text, restic_server_version : Optional Text, stiltcluster_jar_file : Optional Text, btop_version : Optional Text, fd_version : Optional Text, lazygit_version : Optional Text, ripgrep_version : Optional Text, trippy_version : Optional Text, watchexec_version : Optional Text, uv_version : Optional Text, grafana_datasource_version : Optional Text, httm_version : Optional Text })
        , args = None ({ chdir : Text })
        , notify = None Text
        , import_tasks = None Text
        , uri = None ({ url : Text, user : Optional Text, password : Optional Text })
        , systemd = None ({ name : Text, state : Optional Text })
        , copy = None ({ content : Optional Text, dest : Text, backup : Optional Bool, src : Optional Text, mode : Optional Natural })
        , docker_image = None ({ source : Text, name : Text, build : { path : Text } })
        , apt = None ({ name : List Text, state : Optional Text, update_cache : Optional Bool, cache_valid_time : Optional Natural })
        , when = None Text
        , shell = None Text
        , known_hosts = None ({ path : Text, name : Text, key : Text })
        , import_role = None ({ name : Text, tasks_from : Text })
        , template = None ({ dest : Text, src : Text, mode : Optional Text, lstrip_blocks : Optional Bool, backup : Optional Bool, owner : Optional Text })
        , `ansible.builtin.pip` = None ({ virtualenv : Text, virtualenv_command : Text, requirements : Text })
        , include_role = None ({ name : Text })
        , vars = None ({ timer_user : Optional Text, timer_home : Optional Text, timer_name : Optional Text, timer_conf : Optional Text, timer_content : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, nginxsite_domains : Optional (List Text) })
        , slurp = None ({ src : Text })
        , delegate_to = None Text
        , expect = None ({ chdir : Text, command : Text, responses : { `Enter passphrase: ` : Text } })
        , iptables = None ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text })
        , iptables_raw = None ({ name : Text, rules : Text })
        , debug = None ({ msg : Text })
        , tags = None Text
        , `community.postgresql.postgresql_set` = None ({ name : Text, value : Text })
        , user = None ({ name : Text, home : Optional Text, state : Optional Text })
        , run_once = None Bool
        , fetch = None ({ src : Text, dest : Text, flat : Bool })
        , get_url = None ({ url : Text, dest : Text })
        , `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text })
        , fail = None ({ msg : Text })
        , `ansible.builtin.template` = None ({ src : Text, dest : Text, owner : Optional Text })
        , `ansible.builtin.shell` = None Text
        , retries = None Natural
      }
        }

    in  [
        Task::{
          name = Some "Delete docker storage",
          import_role = Some { name = "icos.zfsdocker", tasks_from = "remove.yml" }
        }
    ])
    }
]
