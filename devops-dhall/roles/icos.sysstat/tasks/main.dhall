-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , lineinfile : Optional ({ path : Text, regexp : Text, line : Text, state : Text })
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , lineinfile = None ({ path : Text, regexp : Text, line : Text, state : Text })
    , systemd = None ({ name : Text, enabled : Bool, state : Text })
  }
    }

in  [
    Task::{ name = "Install sysstat", apt = Some { name = [ "sysstat" ] } }
  , Task::{
      name = "Enable sysstat",
      lineinfile = Some {
        path = "/etc/default/sysstat"
      , regexp = "^ENABLED="
      , line = "ENABLED=\"true\""
      , state = "present"
    }
    }
  , Task::{
      name = "Start sysstat service",
      systemd = Some { name = "sysstat", enabled = True, state = "started" }
    }
]
