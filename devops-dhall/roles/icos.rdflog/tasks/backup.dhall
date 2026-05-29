-- Auto-generated from backup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Backup rdflog db",
      include_role = Some {
        name = "icos.bbclient2"
      , apply = None ({ tags : Text })
      , public = Some True
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
      , bbclient_name = Some "{{ rdflog_bbclient_name }}"
      , bbclient_user = Some "root"
      , bbclient_home = Some "{{ rdflog_home }}/bbclient"
      , bbclient_timer_conf = Some "OnCalendar=00/6:11"
      , bbclient_timer_content = Some ''
        #!/bin/bash
        set -eu

        while read repo; do
            export BORG_REPO="$repo"
            docker exec rdflog pg_dump -U rdflog -Cc --if-exists -d rdflog | {{ bbclient_wrapper }} create '::{now}' -;
            {{ bbclient_wrapper }} prune --keep-within=7d --keep-daily=30 --keep-weekly=150
        done < "{{ bbclient_repo_file }}"

      ''
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
    },
      when = Some [ "rdflog_backup_enable | default(False)" ]
    }
  , Task::{
      name = Some "Install rdflog restore scripts",
      template = Some {
        src = "icos-rdflog-restore.sh"
      , dest = "/usr/local/bin/icos-rdflog-restore"
      , mode = Some "+x"
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      when = Some [ "rdflog_backup_enable | default(False)" ]
    }
]
