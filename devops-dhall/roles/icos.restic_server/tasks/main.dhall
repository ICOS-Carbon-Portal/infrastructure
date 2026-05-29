-- Auto-generated from ../../../../devops/roles/icos.restic_server/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "restic_server_setup" ] }
  , Task::{
      name = Some "Check whether restic-rest is installed",
      stat = Some { path = "{{ restic_server_exec }}" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Install/upgrade restic-rest server",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "install.yml", apply = None (({ tags : Text })) }),
      when = Some [ "not _r.stat.exists or restic_server_upgrade" ]
    }
  , Task::{ import_tasks = Some "systemd.yml", tags = Some [ "restic_server_systemd" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "restic_server_just" ] }
  , Task::{ import_tasks = Some "auth.yml", tags = Some [ "restic_server_auth" ] }
]
