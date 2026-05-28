-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , command : Optional Text
    , systemd : Optional ({ daemon_reload : Bool })
    , notify : Optional Text
    , service : Optional Text
  }
    , default =
        { command = None Text
    , systemd = None ({ daemon_reload : Bool })
    , notify = None Text
    , service = None Text
  }
    }

in  [
    Entry::{
      name = "restart {{ servicename }}",
      command = Some "systemctl restart {{ servicename }}"
    }
  , Entry::{ name = "reload systemd config", systemd = Some { daemon_reload = True } }
  , Entry::{
      name = "reload nginx config",
      command = Some "nginx -t",
      notify = Some "really reload nginx config"
    }
  , Entry::{ name = "really reload nginx config", service = Some "name=nginx state=reloaded" }
]
