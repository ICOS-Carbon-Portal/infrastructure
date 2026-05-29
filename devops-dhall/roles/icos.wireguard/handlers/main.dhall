-- Auto-generated from ../../../../devops/roles/icos.wireguard/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "systemd daemon-reload",
      systemd = Some {
        name = None Text,
        state = None Text,
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = Some "True",
        status = None Text
    }
    }
]
