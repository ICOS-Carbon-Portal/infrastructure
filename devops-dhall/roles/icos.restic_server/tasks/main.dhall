-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional Text
    , name : Optional Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , include_tasks : Optional ({ file : Text })
    , when : Optional Text
  }
    , default =
        { import_tasks = None Text
    , tags = None Text
    , name = None Text
    , stat = None ({ path : Text })
    , register = None Text
    , include_tasks = None ({ file : Text })
    , when = None Text
  }
    }

in  [
    Item::{ import_tasks = Some "setup.yml", tags = Some "restic_server_setup" }
  , Item::{
      name = Some "Check whether restic-rest is installed",
      stat = Some { path = "{{ restic_server_exec }}" },
      register = Some "_r"
    }
  , Item::{
      name = Some "Install/upgrade restic-rest server",
      include_tasks = Some { file = "install.yml" },
      when = Some "not _r.stat.exists or restic_server_upgrade"
    }
  , Item::{ import_tasks = Some "systemd.yml", tags = Some "restic_server_systemd" }
  , Item::{ import_tasks = Some "just.yml", tags = Some "restic_server_just" }
  , Item::{ import_tasks = Some "auth.yml", tags = Some "restic_server_auth" }
]
