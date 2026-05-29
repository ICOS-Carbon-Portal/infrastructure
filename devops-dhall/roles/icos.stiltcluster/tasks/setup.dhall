-- Auto-generated from ../../../../devops/roles/icos.stiltcluster/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create stiltcluster user",
      user = Some {
        name = "{{ stiltcluster_username }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = Some "{{ stiltcluster_home }}",
        password_lock = None Bool,
        groups = Some [ "{{ \"docker\" if stiltcluster_docker else omit }}" ],
        append = Some "{{ \"yes\" if stiltcluster_docker else omit }}",
        state = Some "present",
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    }
    }
  , Task::{
      name = Some "Install jre",
      apt = Some {
        name = Some [ "default-jre-headless" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Create bin directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ stiltcluster_bindir }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Install remove-old-stiltruns timer",
      tags = Some [ "stiltcluster_timer" ],
      include_role = Some (Task.Poly_include_role.Record {
          apply = Some { tags = "stiltcluster_timer" },
          name = "icos.timer",
          tasks_from = None Text,
          public = None Bool
      }),
      vars = Some {
        postgresql_backup_host = None Text,
        postgresql_backup_location = None Text,
        container_name = None Text,
        postgresql_user = None Text,
        postgresql_container_name = None Text,
        restheart_backup_host = None Text,
        fsd_name = None Text,
        fsd_target = None Text,
        zfsdocker_name = None Text,
        zfsdocker_size = None Text,
        nginxsite_name = None Text,
        filedrop_domain = None Text,
        filedrop_host = None Text,
        jupyter_domain = None Text,
        jupyter_ip = None Text,
        lxd_forward_name = None Text,
        lxd_forward_ip = None Text,
        certbot_name = None Text,
        certbot_domains = None ((List Text)),
        nginxsite_file = None Text,
        exploredata_name = None Text,
        exploredata_port = None Natural,
        exploredata_host = None Text,
        exploredata_domains = None ((List Text)),
        sshlogin_dst = None Text,
        sshlogin_src_user = None Text,
        sshlogin_dst_user = None Text,
        sshlogin_src_dst_host = None Text,
        sshlogin_src_dst_port = None Text,
        postgresql_postgis_enable = None Bool,
        postgresql_postgres_password = None Text,
        postgresql_listen_addresses = None Text,
        postgresql_pg_stat_enable = None Bool,
        postgresql_backup_script = None Text,
        postgis_bbclient_name = None Text,
        quince_name = None Text,
        quince_domains = None ((List Text)),
        timer_home = Some "/opt/remove-old-stiltruns",
        timer_exec = None Text,
        timer_name = Some "remove-old-stiltruns",
        timer_conf = Some "OnCalendar=daily",
        timer_envs = None ((List Text)),
        timer_content = Some ''
        #!/bin/bash
        # Remove old directories from $HOME/.stiltrun
        #
        # These are created automatically by stilt.py when running stilt simulations. In
        # the normal case they're then removed by the stiltweb backend. This script -
        # run from cron - is an extra safety to keep $HOME to slowly fill up.

        set -u
        set -e

        cd "$HOME/.stiltruns"

        # maxdepth keep it from recursing into directories it's just deleted
        # -mtime is the number of days old the directories may be
        find . -maxdepth 1 -name 'stilt-run-*' -type d -mtime "+10" -exec rm -rf -- '{}' \;

      '',
        timer_user = Some "stiltcluster",
        block = None Text,
        marker = None Text,
        where = None Text,
        state = None Text,
        bbclient_name = None Text,
        bbclient_user = None Text,
        bbclient_home = None Text,
        bbclient_timer_conf = None Text,
        bbclient_timer_content = None Text,
        _restart_needed = None Text,
        fail2ban_config_files = None ((List ({ dest : Text, content : Text }))),
        nginxauth_file = None Text,
        nginxauth_users = None Text,
        jarservice_name = None Text,
        jarservice_home = None Text,
        jarservice_local = None Text,
        jarservice_unit = None Text,
        nginxsite_domains = None ((List Text)),
        jupyter_cert_name = None Text,
        conf = None Text,
        lxd_forward_port = None Text,
        file = None Text,
        keys = None Text,
        set_fact = None Text,
        file_var = None Text,
        python_util_src = None Text,
        nginxauth_name = None Text,
        dbin_download_dest = None Text,
        dbin_user = None Text,
        dbin_repo = None Text,
        dbin_path = None Text,
        dbin_arch = None Text,
        timer_wdir = None Text,
        vmagent_config_dest = None Text,
        vmagent_config_content = None Text,
        dbin_src = None Text,
        dbin_url = None Text,
        _builtin_version = None Text,
        nginxauth_conf = None Text,
        nginxsite_users = None ((List Text)),
        dbin_unar = None Bool,
        timer_state = None Text,
        timer_config = None Text,
        timer_service = None Text
    }
    }
  , Task::{
      name = Some "Remove the remove-old-stiltruns cron job",
      cron = Some {
        user = None Text,
        job = None Text,
        hour = None Text,
        minute = None Text,
        name = "remove old stiltruns",
        state = Some "absent",
        special_time = None Text
    },
      register = Some "_r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "_r.failed", "_r.msg.find('required executable \"crontab\"') < 0" ])
    }
]
