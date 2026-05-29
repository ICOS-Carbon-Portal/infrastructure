-- Auto-generated from ../../../../devops/roles/icos.docker/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload docker",
      service = Some (Task.Poly_service.Record { name = "docker", state = "reloaded", enabled = None Bool })
    }
]
