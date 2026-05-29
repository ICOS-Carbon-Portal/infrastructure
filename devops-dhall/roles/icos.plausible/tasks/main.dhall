-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create home directory",
      file = Some {
        path = Some "{{ plausible_home }}"
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
      include_role = Some {
        name = "icos.nginxsite"
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
      , nginxsite_name = Some "plausible"
      , nginxsite_file = Some "plausible-nginx.conf"
      , _restart_needed = None Text
      , fail2ban_config_files = None (List ({ dest : Text, content : Text }))
      , nginxauth_file = None Text
      , nginxauth_users = None Text
      , jarservice_name = None Text
      , jarservice_home = None Text
      , jarservice_local = None Text
      , jarservice_unit = None Text
      , nginxsite_domains = Some [ "{{ plausible_domain }}" ]
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
  , Task::{
      name = Some "Copy clickhouse-config.xml",
      copy = Some {
        src = Some "clickhouse-config.xml"
      , dest = "{{ plausible_home }}/clickhouse/"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Copy clickhouse-user-config.xml",
      copy = Some {
        src = Some "clickhouse-user-config.xml"
      , dest = "{{ plausible_home }}/clickhouse/"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Copy plausible-conf.env",
      template = Some {
        src = "plausible-conf.env"
      , dest = "{{ plausible_home }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    }
    }
  , Task::{
      name = Some "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml"
      , dest = "{{ plausible_home }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    }
    }
  , Task::{
      name = Some "Run plausible docker compose",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ plausible_home }}"
      , state = Some "present"
      , pull = None Text
      , services = None (List Text)
      , build = None Text
    }
    }
  , Task::{ include_tasks = Some "backup.yml", when = Some [ "plausible_backup_enabled" ] }
]
