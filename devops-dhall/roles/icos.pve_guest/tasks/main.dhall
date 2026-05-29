-- Auto-generated from ../../../../devops/roles/icos.pve_guest/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "terminal.yml", tags = Some [ "pve_guest_terminal" ] }
  , Task::{ import_tasks = Some "setup.yml", tags = Some [ "pve_guest_setup" ] }
  , Task::{
      name = Some "Install icos utilities",
      tags = Some [ "utils" ],
      import_role = Some (Task.Poly_import_role.Record { name = "icos.utils", tasks_from = None Text })
    }
  , Task::{
      name = Some "Add users",
      tags = Some [ "users" ],
      import_role = Some (Task.Poly_import_role.Record { name = "icos.users", tasks_from = None Text })
    }
]
