-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "stiltcluster_setup" ] }
  , Task::{
      import_tasks = Some "config.yml",
      tags = Some [ "stiltcluster_config", "stiltcluster_deploy" ]
    }
  , Task::{ import_tasks = Some "deploy.yml", tags = Some [ "stiltcluster_deploy" ] }
]
