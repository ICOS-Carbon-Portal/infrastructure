-- Auto-generated from main.yml

[
    {
      name = "restart cron"
    , service = { name = "cron", state = "restarted" }
    , register = "_r"
    , failed_when = [ "_r.failed", "_r.msg.find('Could not find the requested service cron') < 0" ]
  }
]
