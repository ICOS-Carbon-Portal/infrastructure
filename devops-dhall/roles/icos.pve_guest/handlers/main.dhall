-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , service : Optional ({ name : Text, state : Text })
    , register : Optional Text
    , failed_when : Optional (List Text)
    , reboot : Optional ({ reboot_timeout : Natural })
  }
    , default =
        { service = None ({ name : Text, state : Text })
    , register = None Text
    , failed_when = None (List Text)
    , reboot = None ({ reboot_timeout : Natural })
  }
    }

in  [
    Entry::{
      name = "restart cron",
      service = Some { name = "cron", state = "restarted" },
      register = Some "_r",
      failed_when = Some [ "_r.failed", "_r.msg.find('Could not find the requested service cron') < 0" ]
    }
  , Entry::{ name = "reboot", reboot = Some { reboot_timeout = 120 } }
]
