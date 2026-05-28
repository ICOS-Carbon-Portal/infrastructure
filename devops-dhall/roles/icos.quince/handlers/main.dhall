-- Auto-generated from main.yml

[
    {
      name = "reload systemd config",
      systemd = { daemon_reload = Some True, name = None Text, state = None Text }
    }
  , {
      name = "restart the quince service",
      systemd = { daemon_reload = None Bool, name = Some "quince", state = Some "restarted" }
    }
  , {
      name = "restart rsyslog",
      systemd = { daemon_reload = None Bool, name = Some "rsyslog", state = Some "restarted" }
    }
]
