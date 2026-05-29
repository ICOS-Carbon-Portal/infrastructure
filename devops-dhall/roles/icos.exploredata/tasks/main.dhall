-- Auto-generated from ../../../../devops/roles/icos.exploredata/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      include_tasks = Some (Task.Poly_include_tasks.Str "setup.yml"),
      loop = Some (Task.Poly_loop.Texts [ "test", "prod" ]),
      loop_control = Some { loop_var = Some "exploredata_type", label = None Text }
    }
]
