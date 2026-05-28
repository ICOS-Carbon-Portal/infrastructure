-- Auto-generated from service.yml

let Entry =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , notify : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text, `daemon-reload` : Bool })
  }
    , default =
        { template = None ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , notify = None Text
    , systemd = None ({ name : Text, enabled : Bool, state : Text, `daemon-reload` : Bool })
  }
    }

in  [
    Entry::{
      name = "Copy nebula.service",
      template = Some { src = "nebula.service", dest = "/etc/systemd/system", lstrip_blocks = True },
      notify = Some "restart nebula"
    }
  , Entry::{
      name = "Start nebula service",
      systemd = Some {
        name = "nebula"
      , enabled = True
      , state = "started"
      , `daemon-reload` = True
    }
    }
]
