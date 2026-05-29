-- Auto-generated from ../../../../devops/roles/icos.cpdata/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "cpdata_setup" ] }
  , Task::{
      import_tasks = Some "deploy.yml",
      tags = Some [ "cpdata_deploy" ],
      when = Some [ "cpdata_jar_file is defined" ]
    }
]
