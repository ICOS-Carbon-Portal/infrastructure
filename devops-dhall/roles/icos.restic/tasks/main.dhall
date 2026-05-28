-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , when : Optional Text
    , tags : Optional Text
    , include_tasks : Optional ({ file : Text })
  }
    , default =
        { stat = None ({ path : Text })
    , register = None Text
    , when = None Text
    , tags = None Text
    , include_tasks = None ({ file : Text })
  }
    }

in  [
    Entry::{
      name = "Check whether restic is installed",
      stat = Some { path = "/usr/local/bin/restic" },
      register = Some "_r"
    }
  , Entry::{
      name = "Install/upgrade restic",
      when = Some "not _r.stat.exists or restic_upgrade",
      tags = Some "restic_install",
      include_tasks = Some { file = "install.yml" }
    }
]
