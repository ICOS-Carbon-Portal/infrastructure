-- Auto-generated from ../../../../devops/roles/icos.stiltweb/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload systemd config",
      systemd = Some {
        name = None Text,
        state = None Text,
        daemon_reload = Some True,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
