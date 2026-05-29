-- Auto-generated from ../../../../devops/roles/icos.mtail/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload mtail",
      service = Some (Task.Poly_service.Record { name = "mtail", state = "restarted", enabled = None Bool })
    }
]
