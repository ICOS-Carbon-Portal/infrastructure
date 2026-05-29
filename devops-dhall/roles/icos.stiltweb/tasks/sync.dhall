-- Auto-generated from sync.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install swiltweb->stilt sync service",
      include_role = Some {
        name = "icos.timer2"
      , apply = Some { tags = "stiltweb_sync" }
      , public = None Bool
      , tasks_from = None Text
    },
      vars = Some {
        timer_home = None Text
      , timer_exec = None Text
      , timer_name = Some "sync-stiltweb-to-stilt"
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
      , timer_state = Some "stopped"
      , timer_config = Some ''
        [Unit]
        Description=Periodically sync stiltweb->stilt

        [Timer]
        OnBootSec=15min
        OnUnitActiveSec=15min

        [Install]
        WantedBy=timers.target

      ''
      , timer_service = Some ''
        [Unit]
        Description=Periodically sync stiltweb->stilt

        [Service]
        User={{ stiltweb_username }}
        WorkingDirectory={{ stiltweb_home }}
        Type=oneshot
        ExecStart={{ stiltweb_bindir }}/sync-stiltweb-to-stilt --sync "{{stiltweb_statedir }}" "{{stiltweb_stiltdir}}"
        Environment=PYTHONUNBUFFERED=1
        # Since this service might run often and since it spawn a lot of
        # parallel processes we use niceness to avoid disrupting other services.
        Nice=10

      ''
    }
    }
]
