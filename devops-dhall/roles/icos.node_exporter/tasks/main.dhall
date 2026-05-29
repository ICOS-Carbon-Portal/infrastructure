-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml" }
  , Task::{ import_tasks = Some "vmagent.yml" }
]
