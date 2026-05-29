-- Auto-generated from coldbackup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install python3-click",
      apt = Some {
        name = Some [ "python3-click" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Create coldbackup helper scripts",
      template = Some {
        src = "{{ item }}"
      , dest = "{{ bbclient_bin_dir }}"
      , mode = Some "+x"
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      loop = Some [ "bbclient-coldbackup", "bbclient-coldrestore" ]
    }
  , Task::{
      name = Some "Add coldbackup systemd timer",
      include_role = Some {
        name = "icos.timer"
      , apply = None ({ tags : Text })
      , public = None Bool
      , tasks_from = None Text
    },
      vars = Some {
        timer_home = Some "{{ bbclient_home }}"
      , timer_exec = Some "{{ bbclient_bin_dir }}/bbclient-coldbackup"
      , timer_name = Some "bbclient-{{ bbclient_name }}-coldbackup"
      , timer_conf = Some ''
        OnCalendar={{ bbclient_coldbackup_hour }}:{{ bbclient_coldbackup_minute }}

      ''
      , timer_envs = Some [ "PYTHONUNBUFFERED=1" ]
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
