-- Auto-generated from main.yml

[
    {
      name = "restart nfs-kernel-server"
    , systemd = { name = "nfs-kernel-server", state = "restarted", `daemon-reload` = True }
  }
]
