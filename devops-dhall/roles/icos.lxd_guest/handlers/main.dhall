-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , systemd : Optional ({ daemon_reload : Bool })
    , service : Optional ({ name : Text, state : Text })
    , register : Optional Text
    , failed_when : Optional (List Text)
  }
    , default =
        { systemd = None ({ daemon_reload : Bool })
    , service = None ({ name : Text, state : Text })
    , register = None Text
    , failed_when = None (List Text)
  }
    }

in  [
    Entry::{ name = "reload systemd config", systemd = Some { daemon_reload = True } }
  , Entry::{
      name = "restart cron",
      service = Some { name = "cron", state = "restarted" },
      register = Some "_r",
      failed_when = Some [ "_r.failed", "_r.msg.find('Could not find the requested service cron') < 0" ]
    }
]
