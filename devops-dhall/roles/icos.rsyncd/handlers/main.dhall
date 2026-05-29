-- Auto-generated from ../../../../devops/roles/icos.rsyncd/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart rsync",
      service = Some (Task.Poly_service.Record { name = "rsync", state = "restarted", enabled = None Bool })
    }
]
