-- Auto-generated from ../../../../devops/roles/icos.cpdata/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart cpdata",
      service = Some (Task.Poly_service.Record { name = "cpdata", state = "restarted", enabled = None Bool })
    }
]
