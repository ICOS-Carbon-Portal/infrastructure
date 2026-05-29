-- Auto-generated from ../../../../devops/roles/icos.fairdatapoint/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "fairdatapoint_setup" ] }
]
