-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , service : Optional ({ name : Text, state : Text })
    , when : Optional Text
    , systemd : Optional ({ daemon_reload : Bool })
  }
    , default =
        { service = None ({ name : Text, state : Text })
    , when = None Text
    , systemd = None ({ daemon_reload : Bool })
  }
    }

in  [
    Entry::{
      name = "restart {{ jarservice_name }}",
      service = Some { name = "{{ jarservice_name }}", state = "restarted" },
      when = Some "jarservice_state | default('started') == 'started'"
    }
  , Entry::{ name = "reload systemd config", systemd = Some { daemon_reload = True } }
]
