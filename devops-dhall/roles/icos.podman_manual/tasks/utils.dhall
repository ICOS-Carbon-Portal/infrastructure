-- Auto-generated from utils.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install docker-compose",
      `community.general.pipx` = Some {
        name = "docker-compose"
      , executable = "pipx-global"
      , python = None Text
      , editable = None Bool
      , force = None Text
    }
    }
  , Task::{
      name = Some "Install docker support for ansible's python",
      pip = Some {
        name = [ "docker", "docker-compose" ]
      , virtualenv = None Text
      , state = None Text
    }
    }
  , Task::{
      include_role = Some {
        name = "icos.github_download_bin"
      , apply = Some { tags = "podman_utils" }
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
      , dbin_download_dest = None Text
      , dbin_user = Some "jesseduffield"
      , dbin_repo = Some "lazydocker"
      , dbin_path = None Text
      , dbin_arch = None Text
      , timer_wdir = None Text
      , vmagent_config_dest = None Text
      , vmagent_config_content = None Text
      , dbin_src = Some "lazydocker"
      , dbin_url = Some "{{ dbin__down }}/v{{ dbin__vers }}/{{ dbin_repo }}_{{ dbin__vers }}_Linux_{{ lazydocker_arch }}.tar.gz"
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
