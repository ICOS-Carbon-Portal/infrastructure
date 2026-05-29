-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      include_tasks = Some "setup.yml",
      loop = Some [ "test", "prod" ],
      loop_control = Some { loop_var = Some "exploredata_type", label = None Text }
    }
]
