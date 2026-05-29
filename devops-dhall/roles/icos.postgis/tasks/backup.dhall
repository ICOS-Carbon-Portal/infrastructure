-- Auto-generated from backup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
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
      , bbclient_name = Some "{{ postgis_bbclient_name }}"
      , bbclient_user = Some "root"
      , bbclient_home = Some "{{ postgis_home }}/bbclient"
      , bbclient_timer_conf = Some ''
        # Run once every 6 hour
        OnCalendar=0:0/6
        # Spread the load for timers starting on a whole hour
        RandomizedDelaySec=10m

      ''
      , bbclient_timer_content = Some ''
        #!/bin/bash

        # strict mode
        set -Eueo pipefail

        # verbose output
        set -x

        # If the repos get moved to another disk - maybe because of storage
        # running out - we don't want the backup to fail.
        export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

        while read repo; do
            export BORG_REPO="$repo"
            docker exec {{ postgis_container_name }} pg_dumpall --clean --if-exists -U postgres | {{ bbclient_wrapper }} create --verbose --stats '::{now}' -

            {{ bbclient_wrapper }} prune --verbose --stats --keep-within=7d --keep-daily=30 --keep-weekly=150

            {{ bbclient_wrapper }} compact
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
    }
    }
]
