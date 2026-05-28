-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text, state : Text })
    , service : Optional ({ name : Text, state : Text, enabled : Bool })
  }
    , default =
        { apt = None ({ name : Text, state : Text })
    , service = None ({ name : Text, state : Text, enabled : Bool })
  }
    }

in  [
    Task::{ name = "Install fail2ban", apt = Some { name = "fail2ban", state = "present" } }
  , Task::{
      name = "Enable fail2ban",
      service = Some { name = "fail2ban", state = "started", enabled = True }
    }
]
