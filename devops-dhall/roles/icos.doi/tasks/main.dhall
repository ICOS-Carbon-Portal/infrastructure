-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "doi_setup" ] }
  , Task::{
      import_tasks = Some "deploy.yml",
      tags = Some [ "doi_deploy" ],
      when = Some [ "doi_jar_file is defined" ]
    }
]
