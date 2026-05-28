-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Text
    , name : Optional Text
    , import_role : Optional ({ name : Text })
  }
    , default =
        { import_tasks = None Text
    , name = None Text
    , import_role = None ({ name : Text })
  }
    }

in  [
    Item::{ import_tasks = Some "terminal.yml", tags = "pve_guest_terminal" }
  , Item::{ import_tasks = Some "setup.yml", tags = "pve_guest_setup" }
  , Item::{
      tags = "utils",
      name = Some "Install icos utilities",
      import_role = Some { name = "icos.utils" }
    }
  , Item::{ tags = "users", name = Some "Add users", import_role = Some { name = "icos.users" } }
]
