-- Auto-generated from ../../../../devops/roles/icos.telegraf/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload telegraf",
      service = Some (Task.Poly_service.Record { name = "telegraf", state = "reloaded", enabled = None Bool })
    }
  , Task::{
      name = Some "restart telegraf",
      service = Some (Task.Poly_service.Record { name = "telegraf", state = "restarted", enabled = None Bool })
    }
]
