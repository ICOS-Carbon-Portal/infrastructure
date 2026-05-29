-- Auto-generated from ../../../../devops/roles/icos.nginxsite/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "make sure we understand nginxsite_state",
      `assert` = Some { that = [ "nginxsite_state in ['present', 'absent']" ], quiet = None Bool }
    }
  , Task::{
      name = Some "add site",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "present.yml", apply = None (({ tags : Text })) }),
      when = Some [ "nginxsite_state == 'present'" ]
    }
  , Task::{
      name = Some "remove site",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "absent.yml", apply = None (({ tags : Text })) }),
      when = Some [ "nginxsite_state == 'absent'" ]
    }
]
