-- Auto-generated from deploy.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy jarfile",
      copy = Some {
        src = Some "{{ cpmeta_jar_file }}"
      , dest = "{{ cpmeta_home }}/cpmeta.jar"
      , mode = None Text
      , content = None Text
      , backup = Some True
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      register = Some "_jarfile"
    }
  , Task::{
      name = Some "Remove all but the five newest of jar file backups",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some {
        creates = None Text
      , chdir = Some "{{ cpmeta_home }}"
      , executable = None Text
      , removes = None Text
    },
      register = Some "_r",
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Task::{
      include_tasks = Some "restart.yml",
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
      , _restart_needed = Some "{{ _config.changed or _jarfile.changed }}"
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
