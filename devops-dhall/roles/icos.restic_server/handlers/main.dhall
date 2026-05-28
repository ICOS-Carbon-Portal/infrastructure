-- Auto-generated from main.yml

[
    {
      name = "restart restic"
    , systemd = { daemon_reload = True, name = "restic-server.socket", state = "restarted" }
  }
]
