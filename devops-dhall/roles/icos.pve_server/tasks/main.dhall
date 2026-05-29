-- Auto-generated from ../../../../devops/roles/icos.pve_server/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "auto_dnat.yml", tags = Some [ "auto_dnat" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "pve_server_just" ] }
]
