-- Auto-generated from ../../../../devops/roles/icos.restic/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check whether restic is installed",
      stat = Some { path = "/usr/local/bin/restic" },
      register = Some "_r"
    }
  , Task::{
      when = Some [ "not _r.stat.exists or restic_upgrade" ],
      tags = Some [ "restic_install" ],
      name = Some "Install/upgrade restic",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "install.yml", apply = None (({ tags : Text })) })
    }
]
