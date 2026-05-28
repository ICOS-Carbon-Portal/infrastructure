-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , include_tasks : Optional ({ file : Text })
    , when : Optional Text
    , import_tasks : Optional Text
    , tags : Optional Text
  }
    , default =
        { name = None Text
    , stat = None ({ path : Text })
    , register = None Text
    , include_tasks = None ({ file : Text })
    , when = None Text
    , import_tasks = None Text
    , tags = None Text
  }
    }

in  [
    Item::{
      name = Some "Check whether borg is installed",
      stat = Some { path = "{{ borg_bin }}" },
      register = Some "_r"
    }
  , Item::{
      name = Some "Install/upgrade borg",
      include_tasks = Some { file = "install.yml" },
      when = Some "not _r.stat.exists or borg_upgrade"
    }
  , Item::{ import_tasks = Some "just.yml", tags = Some "borg_just" }
]
