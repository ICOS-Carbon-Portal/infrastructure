-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "nginx_setup" ] }
  , Task::{ import_tasks = Some "certbot.yml", tags = Some [ "nginx_certbot" ] }
  , Task::{ import_tasks = Some "testing.yml", tags = Some [ "nginx_testing" ] }
  , Task::{
      import_tasks = Some "metrics.yml",
      tags = Some [ "nginx_metrics" ],
      when = Some [ "nginx_metrics_enable" ]
    }
]
