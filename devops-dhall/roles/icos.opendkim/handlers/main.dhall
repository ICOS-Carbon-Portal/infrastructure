-- Auto-generated from main.yml

[
    {
      name = "Restart opendkim"
    , systemd = { name = "opendkim", state = "restarted" }
  }
  , { name = "Restart postfix", systemd = { name = "postfix", state = "restarted" } }
]
