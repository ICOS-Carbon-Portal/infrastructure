-- Auto-generated from main.yml

[
    {
      name = "restart cpmeta"
    , block = [
        {
          name = "Tell cpmeta to switch to readonly mode",
          uri = Some {
            url = "http://{{ cpmeta_host }}}:{{ cpmeta_port }}/admin/switchToReadonlyMode"
        },
          systemd = None ({ name : Text, state : Text })
        }
      , {
          name = "restart the cpmeta systemd service",
          uri = None ({ url : Text }),
          systemd = Some { name = "cpmeta", state = "restarted" }
        }
    ]
  }
]
