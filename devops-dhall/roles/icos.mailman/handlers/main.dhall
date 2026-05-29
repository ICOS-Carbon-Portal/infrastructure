-- Auto-generated from ../../../../devops/roles/icos.mailman/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload nginx config",
      service = Some (Task.Poly_service.Str "name=nginx state=reloaded")
    }
]
