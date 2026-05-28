-- Auto-generated from main.yml

[
    {
      name = "restart icos timer"
    , when = "not ansible_check_mode"
    , systemd = { name = "{{ timer_name }}.timer", state = "restarted" }
  }
]
