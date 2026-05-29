-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Build and deploy docker images",
      import_tasks = Some "docker.yml",
      tags = Some [ "nexus_docker" ]
    }
  , Task::{
      name = Some "Create certificate and create nginx config",
      import_tasks = Some "nginx.yml",
      tags = Some [ "nexus_nginx" ]
    }
]
