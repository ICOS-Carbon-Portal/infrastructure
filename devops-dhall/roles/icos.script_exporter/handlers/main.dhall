-- Auto-generated from ../../../../devops/roles/icos.script_exporter/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload script-exporter",
      systemd = Some {
        name = Some "script-exporter",
        state = Some "reloaded",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
