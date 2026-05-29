-- Auto-generated from ../../../../devops/roles/icos.xcaddy/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_role = Some (Task.Poly_import_role.Str "name=icos.golang") }
  , Task::{
      import_tasks = Some "xcaddy-debian.yml",
      when = Some [ "ansible_distribution_file_variety == 'Debian'" ]
    }
  , Task::{
      import_tasks = Some "xcaddy-other.yml",
      when = Some [ "ansible_distribution_file_variety != 'Debian'" ]
    }
]
