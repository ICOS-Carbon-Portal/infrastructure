-- Auto-generated from ../../../../devops/roles/icos.rdflog/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "barebones.yml", tags = Some [ "rdflog_setup" ] }
]
