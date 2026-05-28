-- Auto-generated from cleanup.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ src : Text, dest : Text })
    , loop : Optional (List Text)
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text, daemon_reload : Bool })
  }
    , default =
        { copy = None ({ src : Text, dest : Text })
    , loop = None (List Text)
    , systemd = None ({ name : Text, enabled : Bool, state : Text, daemon_reload : Bool })
  }
    }

in  [
    Task::{
      name = "Copy docker-periodic-cleanup.timer",
      copy = Some { src = "{{ item }}", dest = "/etc/systemd/system" },
      loop = Some [ "docker-periodic-cleanup.timer", "docker-periodic-cleanup.service" ]
    }
  , Task::{
      name = "Start docker-periodic-cleanup.timer",
      systemd = Some {
        name = "docker-periodic-cleanup.timer"
      , enabled = True
      , state = "started"
      , daemon_reload = True
    }
    }
]
