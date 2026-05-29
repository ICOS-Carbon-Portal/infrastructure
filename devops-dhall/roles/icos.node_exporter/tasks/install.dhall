-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create node_exporter user",
      user = Some {
        name = "{{ node_exporter_user }}"
      , home = Some "{{ node_exporter_home }}"
      , create_home = None Text
      , shell = Some "/usr/sbin/nologin"
      , groups = None (List Text)
      , append = None Text
      , state = None Text
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
  , Task::{
      name = Some "Download node_exporter",
      include_role = Some {
        name = "icos.github_download_bin"
      , apply = None ({ tags : Text })
      , public = None Bool
      , tasks_from = None Text
    },
      vars = Some {
        timer_home = None Text
      , timer_exec = None Text
      , timer_name = None Text
      , timer_conf = None Text
      , timer_envs = None (List Text)
      , timer_content = None Text
      , timer_user = None Text
      , block = None Text
      , marker = None Text
      , where = None Text
      , state = None Text
      , bbclient_name = None Text
      , bbclient_user = None Text
      , bbclient_home = None Text
      , bbclient_timer_conf = None Text
      , bbclient_timer_content = None Text
      , certbot_name = None Text
      , certbot_domains = None (List Text)
      , nginxsite_name = None Text
      , nginxsite_file = None Text
      , _restart_needed = None Text
      , fail2ban_config_files = None (List ({ dest : Text, content : Text }))
      , nginxauth_file = None Text
      , nginxauth_users = None Text
      , jarservice_name = None Text
      , jarservice_home = None Text
      , jarservice_local = None Text
      , jarservice_unit = None Text
      , nginxsite_domains = None (List Text)
      , jupyter_cert_name = None Text
      , conf = None Text
      , lxd_forward_name = None Text
      , lxd_forward_ip = None Text
      , lxd_forward_port = None Text
      , file = None Text
      , keys = None Text
      , zfsdocker_size = None Text
      , set_fact = None Text
      , file_var = None Text
      , python_util_src = None Text
      , nginxauth_name = None Text
      , dbin_download_dest = Some "{{ node_exporter_download }}"
      , dbin_user = Some "prometheus"
      , dbin_repo = Some "node_exporter"
      , dbin_path = Some "node_exporter"
      , dbin_arch = Some "{{ node_exporter_arch }}"
      , timer_wdir = None Text
      , vmagent_config_dest = None Text
      , vmagent_config_content = None Text
      , dbin_src = None Text
      , dbin_url = None Text
      , _builtin_version = None Text
      , nginxauth_conf = None Text
      , nginxsite_users = None (List Text)
      , dbin_unar = None Bool
      , timer_state = None Text
      , timer_config = None Text
      , timer_service = None Text
    }
    }
  , Task::{
      name = Some "Create the textfile collector directory",
      file = Some {
        path = Some "{{ node_exporter_textfiles }}"
      , state = Some "directory"
      , mode = Some "1777"
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Copy node-exporter systemd files",
      template = Some {
        src = "{{ item }}"
      , dest = "/etc/systemd/system/"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      loop = Some [ "node-exporter.service", "node-exporter.socket" ],
      notify = Some [ "restart node-exporter" ]
    }
  , Task::{
      name = Some "Create the EnvironmentFile used by the systemd service",
      copy = Some {
        src = None Text
      , dest = "{{ node_exporter_environ }}"
      , mode = None Text
      , content = Some ''
        OPTIONS=--collector.textfile.directory={{ node_exporter_textfiles }}

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Enable and start node-exporter.socket",
      systemd = Some {
        name = Some "node-exporter.socket"
      , state = Some "started"
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = Some "True"
      , status = None Text
    }
    }
  , Task::{
      name = Some "Allow node_exporter through firewall",
      iptables_raw = Some {
        name = "allow_node_exporter"
      , rules = Some "-A INPUT -p tcp --dport {{ node_exporter_listen }} -j ACCEPT"
      , weight = None Natural
      , table = None Text
      , state = Some "{{ 'present' if node_exporter_allow else 'absent' }}"
    }
    }
]
