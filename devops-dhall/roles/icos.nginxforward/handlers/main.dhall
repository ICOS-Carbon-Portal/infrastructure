-- Auto-generated from ../../../../devops/roles/icos.nginxforward/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload nginx config",
      shell = Some ''
      nginx -t && systemctl reload nginx

    ''
    }
]
