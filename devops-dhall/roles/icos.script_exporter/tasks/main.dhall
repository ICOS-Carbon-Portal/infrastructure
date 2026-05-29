-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Download script_exporter",
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
      , dbin_download_dest = Some "{{ dbin_download_base }}/script-exporter-{{ dbin__vers }}"
      , dbin_user = Some "ricoberger"
      , dbin_repo = Some "script_exporter"
      , dbin_path = None Text
      , dbin_arch = None Text
      , timer_wdir = None Text
      , vmagent_config_dest = None Text
      , vmagent_config_content = None Text
      , dbin_src = None Text
      , dbin_url = Some "{{ dbin__down }}/v{{ dbin__vers }}/script_exporter-linux-{{ sexp_arch }}"
      , _builtin_version = None Text
      , nginxauth_conf = None Text
      , nginxsite_users = None (List Text)
      , dbin_unar = Some False
      , timer_state = None Text
      , timer_config = None Text
      , timer_service = None Text
    }
    }
  , Task::{
      name = Some "Create script_exporter home directory",
      file = Some {
        path = Some "{{ sexp_home }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Add base config for script-exporter",
      blockinfile = Some {
        marker = "# {mark} base config"
      , state = None Text
      , create = Some True
      , insertafter = Some "BOF"
      , path = "{{ sexp_config_file }}"
      , block = Some "{{ lookup('template', 'config.yaml') }}"
      , insertbefore = None Text
    },
      notify = Some [ "reload script-exporter" ]
    }
  , Task::{ import_tasks = Some "scripts.yml" }
  , Task::{
      name = Some "Copy script-exporter systemd files",
      template = Some {
        src = "script-exporter.service"
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
      register = Some "_sysd"
    }
  , Task::{
      name = Some "Start/restart script-exporter.service",
      systemd = Some {
        name = Some "script-exporter.service"
      , state = Some "started"
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = Some "{{ 'yes' if _sysd.changed else 'no' }}"
      , status = None Text
    }
    }
  , Task::{
      name = Some "Add ourselves to the local vmagent installation",
      include_role = Some {
        name = "icos.vmagent"
      , apply = None ({ tags : Text })
      , public = None Bool
      , tasks_from = Some "add_config"
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
      , dbin_download_dest = None Text
      , dbin_user = None Text
      , dbin_repo = None Text
      , dbin_path = None Text
      , dbin_arch = None Text
      , timer_wdir = None Text
      , vmagent_config_dest = Some "script-exporter-scripts.yaml"
      , vmagent_config_content = Some ''
        # These are the scripts exported by script-exporter.
        - job_name: script-exporter
          http_sd_configs:
            - url: http://localhost:9469/discovery
          relabel_configs:
            - target_label: instance
              replacement: {{ inventory_hostname_short }}

      ''
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
]
