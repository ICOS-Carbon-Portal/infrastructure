-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "quince-system.yml", tags = Some [ "quince-system" ] }
  , Task::{
      name = Some "Download specific version of tomcat",
      tags = Some [ "quince-setup", "quince-tomcat" ],
      import_tasks = Some "quince-tomcat.yml"
    }
  , Task::{
      name = Some "Setup mysql database",
      tags = Some [ "quince-setup", "quince-mysql" ],
      import_tasks = Some "quince-mysql.yml"
    }
  , Task::{
      name = Some "Install backup script",
      tags = Some [ "quince-backup", "quince-backup-script" ],
      import_tasks = Some "quince-backup.yml"
    }
  , Task::{ import_tasks = Some "quince-logging.yml", tags = Some [ "quince-logging" ] }
]
