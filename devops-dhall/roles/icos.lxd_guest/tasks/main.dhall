-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "lxd_guest_setup" ] }
  , Task::{
      name = Some "Install icos utilities",
      tags = Some [ "utils" ],
      import_role = Some { name = "icos.utils" }
    }
  , Task::{
      name = Some "Add users",
      tags = Some [ "users" ],
      import_role = Some { name = "icos.users" }
    }
]
