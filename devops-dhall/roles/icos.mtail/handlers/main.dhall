-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload mtail",
      service = Some { name = "mtail", state = "restarted", enabled = None Bool }
    }
]
