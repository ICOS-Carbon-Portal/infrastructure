-- Auto-generated from ../../../../devops/roles/ops.zfs/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "just.yml", tags = Some [ "zfs_just" ] }
  , Task::{
      name = Some "Check whether httm is installed",
      tags = Some [ "httm" ],
      stat = Some { path = "/usr/bin/httm" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Install/upgrade httm",
      tags = Some [ "httm" ],
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "httm.yml", apply = None (({ tags : Text })) }),
      when = Some [ "not _r.stat.exists or httm_upgrade" ]
    }
]
