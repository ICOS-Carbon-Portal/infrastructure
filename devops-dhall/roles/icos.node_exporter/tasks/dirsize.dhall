-- Auto-generated from dirsize.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create dirsize home directory",
      file = Some {
        path = Some "{{ dirsize_home }}"
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
      name = Some "Make sure that the dirnames file exists.",
      copy = Some {
        src = None Text
      , dest = "{{ dirsize_dirnames }}"
      , mode = None Text
      , content = Some ""
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = Some "False"
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Ensure that initial directories are in dirnames.txt",
      lineinfile = Some {
        path = "{{ dirsize_dirnames }}"
      , line = Some "{{ item }}"
      , state = Some "present"
      , regex = None Text
      , regexp = None Text
      , create = None Bool
      , owner = None Text
      , group = None Text
      , insertafter = None Text
      , mode = None Natural
      , insertbefore = None Text
    },
      loop = Some [ "{{ dirsize_initial }}" ]
    }
  , Task::{
      name = Some "Create timer for node-exporter-dirsize",
      include_role = Some {
        name = "icos.timer"
      , apply = None ({ tags : Text })
      , public = None Bool
      , tasks_from = None Text
    },
      vars = Some {
        timer_home = Some "{{ dirsize_home }}"
      , timer_exec = None Text
      , timer_name = Some "node-exporter-dirsize"
      , timer_conf = Some "OnCalendar=hourly"
      , timer_envs = None (List Text)
      , timer_content = Some ''
        #!/bin/bash
        # Read directory name from a file that can be dynamically populated by
        # ansible.
        xargs -r -a {{ dirsize_dirnames }} {{ dirsize_sh }} | uniq | sponge {{ dirsize_prom }}

      ''
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
