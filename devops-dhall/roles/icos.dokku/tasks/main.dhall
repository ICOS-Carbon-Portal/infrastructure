-- Auto-generated from ../../../../devops/roles/icos.dokku/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml", tags = Some [ "dokku_install" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "dokku_just" ] }
]
