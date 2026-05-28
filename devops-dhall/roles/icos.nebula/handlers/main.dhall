-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , service : Optional ({ name : Text, state : Text })
    , when : Optional Text
    , notify : Optional Text
    , systemd : Optional ({ name : Optional Text, state : Optional Text, daemon_reload : Optional Bool })
  }
    , default =
        { service = None ({ name : Text, state : Text })
    , when = None Text
    , notify = None Text
    , systemd = None ({ name : Optional Text, state : Optional Text, daemon_reload : Optional Bool })
  }
    }

in  [
    Entry::{ name = "reload nebula", service = Some { name = "nebula", state = "reloaded" } }
  , Entry::{ name = "restart nebula", service = Some { name = "nebula", state = "restarted" } }
  , Entry::{
      name = "restart systemd-networkd",
      service = Some { name = "systemd-networkd", state = "restarted" },
      notify = Some "restart NetworkManager"
    }
  , Entry::{
      name = "restart NetworkManager",
      systemd = Some {
        name = Some "NetworkManager"
      , state = Some "restarted"
      , daemon_reload = None Bool
    }
    }
  , Entry::{
      name = "reload NetworkManager",
      systemd = Some {
        name = Some "NetworkManager"
      , state = Some "reloaded"
      , daemon_reload = None Bool
    }
    }
  , Entry::{
      name = "systemd reload",
      systemd = Some { name = None Text, state = None Text, daemon_reload = Some True }
    }
]
