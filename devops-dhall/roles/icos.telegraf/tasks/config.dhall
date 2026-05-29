-- Auto-generated from config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_tasks = Some "config_present.yml",
      when = Some [ "telegraf_config_state == \"present\"" ]
    }
  , Task::{
      import_tasks = Some "config_absent.yml",
      when = Some [ "telegraf_config_state == \"absent\"" ]
    }
]
