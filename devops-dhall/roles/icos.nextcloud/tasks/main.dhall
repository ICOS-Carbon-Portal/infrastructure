-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "nextcloud_setup" ] }
  , Task::{ import_tasks = Some "nginx.yml", tags = Some [ "nextcloud_nginx" ] }
  , Task::{
      import_tasks = Some "prometheus.yml",
      tags = Some [ "nextcloud_prometheus" ],
      when = Some [ "nextcloud_exporter_pass is defined" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "nextcloud_just" ] }
]
