-- Auto-generated from ../../../../devops/roles/icos.certbot/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_tasks = Some "certbot.yml",
      tags = Some [ "certbot_only" ],
      when = Some [ "not certbot_disabled" ]
    }
]
