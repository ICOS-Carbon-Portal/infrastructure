-- Auto-generated from ../../../../devops/roles/icos.telegraf/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml", tags = Some [ "telegraf_install" ] }
  , Task::{
      import_tasks = Some "smart.yml",
      tags = Some [ "telegraf_smart" ],
      when = Some [ "telegraf_smart_enable" ]
    }
  , Task::{ import_tasks = Some "config.yml", tags = Some [ "telegraf_config" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "telegraf_just" ] }
]
