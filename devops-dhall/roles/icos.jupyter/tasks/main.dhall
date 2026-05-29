-- Auto-generated from ../../../../devops/roles/icos.jupyter/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "jupyter_setup" ] }
  , Task::{ import_tasks = Some "registry.yml", tags = Some [ "jupyter_registry" ] }
  , Task::{
      import_tasks = Some "jusers.yml",
      tags = Some [ "jupyter_jusers" ],
      when = Some [ "jupyter_jusers_enable" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "jupyter_just" ] }
]
