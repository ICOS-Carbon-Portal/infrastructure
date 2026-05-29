-- Auto-generated from ../../../../devops/roles/icos.zrepl/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml", tags = Some [ "zrepl_install" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "zrepl_just" ] }
  , Task::{ import_tasks = Some "config.yml", tags = Some [ "zrepl_config" ] }
]
