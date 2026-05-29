-- Auto-generated from ../../../../devops/roles/icos.filedrop/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart filedrop",
      systemd = Some {
        name = Some "filedrop",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
