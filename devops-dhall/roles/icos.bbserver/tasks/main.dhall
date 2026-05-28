-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Text
    , name : Optional Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , when : Optional Text
  }
    , default =
        { import_tasks = None Text
    , name = None Text
    , stat = None ({ path : Text })
    , register = None Text
    , when = None Text
  }
    }

in  [
    Item::{ import_tasks = Some "setup.yml", tags = "bbserver_setup" }
  , Item::{ import_tasks = Some "cli.yml", tags = "bbserver_cli" }
  , Item::{
      tags = "bbserver_monitor",
      name = Some "Check whether {{ bbserver_textfiles }} exists",
      stat = Some { path = "{{ bbserver_textfiles }}" },
      register = Some "_textfiles"
    }
  , Item::{
      import_tasks = Some "monitor.yml",
      tags = "bbserver_monitor",
      when = Some "_textfiles.stat.exists"
    }
]
