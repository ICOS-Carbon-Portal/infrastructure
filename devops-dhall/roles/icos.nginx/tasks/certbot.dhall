-- Auto-generated from certbot.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install certbot using snap",
      `community.general.snap` = Some { name = "certbot", classic = True }
    }
  , Task::{
      name = Some "Add job to renew certificates",
      cron = Some {
        user = None Text
      , job = Some "{{ nginx_certbot_bin }} renew -q"
      , hour = None Text
      , minute = None Text
      , name = "Certbot renewal"
      , state = None Text
      , special_time = Some "daily"
    }
    }
  , Task::{
      name = Some "Create /etc/letsencrypt/renewal-hooks/deploy directory",
      file = Some {
        path = Some "/etc/letsencrypt/renewal-hooks/deploy"
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
      name = Some "Add a nginx deploy-hook for certbot",
      copy = Some {
        src = None Text
      , dest = "/etc/letsencrypt/renewal-hooks/deploy/nginx.sh"
      , mode = Some "+x"
      , content = Some ''
        #!/bin/bash
        service nginx reload

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Install the icos-certbot util",
      tags = Some [ "certbot_utils" ],
      import_role = Some { name = "icos.python_util" },
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
      , python_util_src = Some "certbot_util"
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
