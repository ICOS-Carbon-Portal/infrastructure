-- Auto-generated from ../../../../devops/roles/icos.certbot/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload nginx config",
      command = Some "nginx -t",
      notify = Some [ "really reload nginx config" ]
    }
  , Task::{
      name = Some "really reload nginx config",
      service = Some (Task.Poly_service.Record { name = "nginx", state = "reloaded", enabled = None Bool })
    }
]
