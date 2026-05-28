-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Text
    , name : Optional Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , include_tasks : Optional ({ file : Text })
    , when : Optional Text
  }
    , default =
        { import_tasks = None Text
    , name = None Text
    , stat = None ({ path : Text })
    , register = None Text
    , include_tasks = None ({ file : Text })
    , when = None Text
  }
    }

in  [
    Item::{ import_tasks = Some "just.yml", tags = "zfs_just" }
  , Item::{
      tags = "httm",
      name = Some "Check whether httm is installed",
      stat = Some { path = "/usr/bin/httm" },
      register = Some "_r"
    }
  , Item::{
      tags = "httm",
      name = Some "Install/upgrade httm",
      include_tasks = Some { file = "httm.yml" },
      when = Some "not _r.stat.exists or httm_upgrade"
    }
]
