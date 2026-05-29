-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "stiltweb_setup" ] }
  , Task::{ import_tasks = Some "deploy.yml", tags = Some [ "stiltweb_deploy" ] }
  , Task::{ import_tasks = Some "utils.yml", tags = Some [ "stiltweb_utils" ] }
  , Task::{ import_tasks = Some "sync.yml", tags = Some [ "stiltweb_sync" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "stiltweb_just" ] }
]
