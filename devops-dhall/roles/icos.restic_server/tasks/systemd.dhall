-- Auto-generated from systemd.yml

let Entry =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop : Optional (List Text)
    , notify : Optional Text
    , systemd : Optional ({ name : Text, state : Text })
  }
    , default =
        { template = None ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop = None (List Text)
    , notify = None Text
    , systemd = None ({ name : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Copy systemd service files",
      template = Some { src = "{{ item }}", dest = "/etc/systemd/system", lstrip_blocks = True },
      loop = Some [ "restic-server.service", "restic-server.socket" ],
      notify = Some "restart restic"
    }
  , Entry::{
      name = "Start restic socket",
      systemd = Some { name = "restic-server.socket", state = "started" }
    }
]
