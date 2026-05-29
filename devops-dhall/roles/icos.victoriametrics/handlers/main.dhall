-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload docker",
      service = Some { name = "docker", state = "reloaded", enabled = None Bool }
    }
]
