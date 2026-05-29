-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart cpdata",
      service = Some { name = "cpdata", state = "restarted", enabled = None Bool }
    }
]
