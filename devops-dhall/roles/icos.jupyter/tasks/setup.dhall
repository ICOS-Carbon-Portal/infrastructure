-- Auto-generated from ../../../../devops/roles/icos.jupyter/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create jupyter home",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ jupyter_home }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Create auth token",
      shell = Some "openssl rand -hex 20 | awk '{ print \"CONFIGPROXY_AUTH_TOKEN=\" $1 }' > auth_token.env",
      args = Some {
        chdir = Some "{{ jupyter_home }}",
        creates = Some "auth_token.env",
        executable = None Text,
        removes = None Text
    }
    }
  , Task::{ name = Some "Create jupyter network", docker_network = Some { name = "jupyter" } }
  , Task::{
      name = Some "Copy files",
      copy = Some {
        dest = "{{ jupyter_home }}",
        mode = None Text,
        content = None Text,
        src = Some "{{ item }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "build.hub", "docker-compose.yml" ])
    }
  , Task::{
      name = Some "Copy jupyterhub_config.py",
      template = Some {
        src = "jupyterhub_config.py",
        dest = "{{ jupyter_home }}/jupyterhub_home/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
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
        lxd_forward_name = None Text,
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
        conf = Some "{{ jupyter_hub_config_defaults | combine(jupyter_hub_config) }}",
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
    },
      register = Some "_config"
    }
  , Task::{
      name = Some "Start proxy and hub",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ jupyter_home }}",
        state = None Text,
        pull = None Text,
        services = None ((List Text)),
        build = None Text
    }
    }
  , Task::{
      name = Some "Restart the hub",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ jupyter_home }}",
        state = Some "restarted",
        pull = None Text,
        services = Some [ "hub" ],
        build = Some "always"
    },
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
