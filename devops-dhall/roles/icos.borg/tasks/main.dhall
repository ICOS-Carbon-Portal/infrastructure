-- Auto-generated from ../../../../devops/roles/icos.borg/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check whether borg is installed",
      stat = Some { path = "{{ borg_bin }}" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Install/upgrade borg",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "install.yml", apply = None (({ tags : Text })) }),
      when = Some [ "not _r.stat.exists or borg_upgrade" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "borg_just" ] }
]
