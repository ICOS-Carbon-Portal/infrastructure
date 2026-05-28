-- Auto-generated from sync.yml

[
    {
      name = "Install swiltweb->stilt sync service"
    , include_role = { name = "icos.timer2", apply = { tags = "stiltweb_sync" } }
    , vars = {
        timer_state = "stopped"
      , timer_name = "sync-stiltweb-to-stilt"
      , timer_config = ''
        [Unit]
        Description=Periodically sync stiltweb->stilt

        [Timer]
        OnBootSec=15min
        OnUnitActiveSec=15min

        [Install]
        WantedBy=timers.target

      ''
      , timer_service = ''
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
