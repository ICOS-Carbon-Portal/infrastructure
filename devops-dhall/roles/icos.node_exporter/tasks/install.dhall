-- Auto-generated from ../../../../devops/roles/icos.node_exporter/tasks/install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create node_exporter user",
      user = Some {
        name = "{{ node_exporter_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/usr/sbin/nologin",
        home = Some "{{ node_exporter_home }}",
        password_lock = None Bool,
        groups = None ((List Text)),
        append = None Text,
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    }
    }
  , Task::{
      name = Some "Download node_exporter",
      include_role = Some (Task.Poly_include_role.Record {
          apply = None (({ tags : Text })),
          name = "icos.github_download_bin",
          tasks_from = None Text,
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
        conf = None Text,
        lxd_forward_port = None Text,
        file = None Text,
        keys = None Text,
        set_fact = None Text,
        file_var = None Text,
        python_util_src = None Text,
        nginxauth_name = None Text,
        dbin_download_dest = Some "{{ node_exporter_download }}",
        dbin_user = Some "prometheus",
        dbin_repo = Some "node_exporter",
        dbin_path = Some "node_exporter",
        dbin_arch = Some "{{ node_exporter_arch }}",
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
      name = Some "Create the textfile collector directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ node_exporter_textfiles }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "1777",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Copy node-exporter systemd files",
      template = Some {
        src = "{{ item }}",
        dest = "/etc/systemd/system/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "node-exporter.service", "node-exporter.socket" ]),
      notify = Some [ "restart node-exporter" ]
    }
  , Task::{
      name = Some "Create the EnvironmentFile used by the systemd service",
      copy = Some {
        dest = "{{ node_exporter_environ }}",
        mode = None Text,
        content = Some ''
        OPTIONS=--collector.textfile.directory={{ node_exporter_textfiles }}

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Enable and start node-exporter.socket",
      systemd = Some {
        name = Some "node-exporter.socket",
        state = Some "started",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = Some "True",
        status = None Text
    }
    }
  , Task::{
      name = Some "Allow node_exporter through firewall",
      iptables_raw = Some {
        name = "allow_node_exporter",
        rules = Some "-A INPUT -p tcp --dport {{ node_exporter_listen }} -j ACCEPT",
        table = None Text,
        state = Some "{{ 'present' if node_exporter_allow else 'absent' }}",
        weight = None Natural
    }
    }
]
