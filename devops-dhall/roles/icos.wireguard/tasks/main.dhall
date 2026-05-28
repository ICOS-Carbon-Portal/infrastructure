-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , name : Optional Text
    , copy : Optional ({ src : Text, dest : Text, mode : Text })
  }
    , default =
        { import_tasks = None Text
    , name = None Text
    , copy = None ({ src : Text, dest : Text, mode : Text })
  }
    }

in  [
    Item::{ import_tasks = Some "install.yml" }
  , Item::{ import_tasks = Some "keys.yml" }
  , Item::{ import_tasks = Some "reresolve.yml" }
  , Item::{
      name = Some "Install wg(1) overlay",
      copy = Some { src = "wg.py", dest = "/usr/local/bin/wg", mode = "+x" }
    }
]
