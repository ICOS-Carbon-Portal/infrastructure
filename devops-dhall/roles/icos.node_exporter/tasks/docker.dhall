-- Auto-generated from docker.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "pip install docker",
      pip = Some { name = [ "docker" ], virtualenv = None Text, state = Some "present" }
    }
  , Task::{
      name = Some "Create dockermon timer",
      include_role = Some {
        name = "icos.timer"
      , apply = None ({ tags : Text })
      , public = None Bool
      , tasks_from = None Text
    },
      vars = Some {
        timer_home = Some "{{ dockermon_home }}"
      , timer_exec = Some "/bin/bash -c 'set -o pipefail && {{ timer_dest }} | uniq | sponge {{ dockermon_prom }}'"
      , timer_name = Some "node-exporter-dockermon"
      , timer_conf = Some "OnCalendar=*:0/5"
      , timer_envs = Some [ "PYTHONUNBUFFERED=1", "PATH=/usr/bin:/usr/local/bin" ]
      , timer_content = Some "{{ lookup('template', 'dockermon.py') }}"
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
]
