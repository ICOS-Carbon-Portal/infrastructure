-- Auto-generated from ../../../../devops/roles/icos.cpauth/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "cpauth_setup" ] }
  , Task::{
      import_tasks = Some "deploy.yml",
      tags = Some [ "cpauth_deploy" ],
      when = Some [ "cpauth_jar_file is defined" ]
    }
  , Task::{ import_tasks = Some "backup.yml", tags = Some [ "cpauth_backup" ] }
]
