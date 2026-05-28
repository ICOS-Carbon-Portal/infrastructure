-- Auto-generated from main.yml

[
    {
      name = "restart icos timer"
    , systemd = { name = "{{ timer_name }}.timer", state = "restarted" }
  }
]
