-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart rsync",
      service = Some { name = "rsync", state = "restarted", enabled = None Bool }
    }
]
