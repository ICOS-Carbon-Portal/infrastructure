-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : Text
    , when : Optional Text
  }
    , default =
        { when = None Text
  }
    }

in  [
    Item::{ import_tasks = "install.yml", tags = "vmagent_install" }
  , Item::{ import_tasks = "systemd.yml", tags = "vmagent_systemd" }
  , Item::{
      import_tasks = "proxy.yml",
      tags = "vmagent_proxy",
      when = Some "vmagent_proxy != \"disabled\""
    }
  , Item::{ import_tasks = "just.yml", tags = "vmagent_just" }
]
