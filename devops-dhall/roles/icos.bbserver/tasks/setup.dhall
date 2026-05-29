-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create bbserver user",
      user = Some {
        name = "{{ bbserver_user }}"
      , home = Some "{{ bbserver_home | default(omit) }}"
      , create_home = Some "True"
      , shell = Some "/usr/bin/bash"
      , groups = None (List Text)
      , append = None Text
      , state = None Text
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
  , Task::{
      name = Some "Change access rights on bbserver_home",
      file = Some {
        path = Some "{{ bbserver_home }}"
      , state = None Text
      , mode = Some "448"
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Create repo directory",
      file = Some {
        path = Some "{{ bbserver_repo_home }}"
      , state = Some "directory"
      , mode = None Text
      , owner = Some "{{ bbserver_user }}"
      , group = Some "{{ bbserver_user }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Install borg-compact timer",
      include_role = Some {
        name = "icos.timer"
      , apply = Some { tags = "bbserver_compact" }
      , public = None Bool
      , tasks_from = None Text
    },
      vars = Some {
        timer_home = Some "{{ bbserver_home }}/bbserver-compact"
      , timer_exec = None Text
      , timer_name = Some "bbserver-compact"
      , timer_conf = Some ''
        OnCalendar=weekly
        RandomizedDelaySec=3h

      ''
      , timer_envs = Some [
          "BORG_RELOCATED_REPO_ACCESS_IS_OK=yes"
        , "BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes"
      ]
      , timer_content = Some ''
        #!/bin/bash
        # Since borg 1.2, it's not enough to prune repos, they have to be
        # compacted as well.
        set -eux

        cd $HOME/repos
        for repo in *.repo; do
          time borg compact --verbose $repo
        done

      ''
      , timer_user = Some "{{ bbserver_user }}"
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
    },
      tags = Some [ "bbserver_compact" ]
    }
]
