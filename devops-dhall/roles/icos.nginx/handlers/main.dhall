-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , command : Optional Text
    , notify : Optional Text
    , service : Optional ({ name : Text, state : Text })
    , systemd : Optional ({ daemon_reload : Optional Bool, `daemon-reload` : Optional Bool, name : Optional Text, state : Optional Text })
  }
    , default =
        { command = None Text
    , notify = None Text
    , service = None ({ name : Text, state : Text })
    , systemd = None ({ daemon_reload : Optional Bool, `daemon-reload` : Optional Bool, name : Optional Text, state : Optional Text })
  }
    }

in  [
    Entry::{
      name = "reload nginx config",
      command = Some "nginx -t",
      notify = Some "really reload nginx config"
    }
  , Entry::{
      name = "really reload nginx config",
      service = Some { name = "nginx", state = "reloaded" }
    }
  , Entry::{
      name = "reload systemd config",
      systemd = Some {
        daemon_reload = Some True
      , `daemon-reload` = None Bool
      , name = None Text
      , state = None Text
    }
    }
  , Entry::{
      name = "restart nginx-prometheus-exporter",
      systemd = Some {
        daemon_reload = None Bool
      , `daemon-reload` = Some True
      , name = Some "nginx-prometheus-exporter"
      , state = Some "restarted"
    }
    }
]
