-- Auto-generated from ../../../../devops/roles/icos.jbuild/handlers/default.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload sshd",
      systemd = Some {
        name = Some "sshd",
        state = Some "reloaded",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
