-- Auto-generated from ../../../../devops/roles/icos.postgresql/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload postgresql",
      systemd = Some {
        name = Some "postgresql",
        state = None Text,
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = Some "reloaded"
    }
    }
  , Task::{
      name = Some "restart postgresql",
      systemd = Some {
        name = Some "postgresql",
        state = None Text,
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = Some "restarted"
    }
    }
]
