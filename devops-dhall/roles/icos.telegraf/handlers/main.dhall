-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload telegraf",
      service = Some { name = "telegraf", state = "reloaded", enabled = None Bool }
    }
  , Task::{
      name = Some "restart telegraf",
      service = Some { name = "telegraf", state = "restarted", enabled = None Bool }
    }
]
