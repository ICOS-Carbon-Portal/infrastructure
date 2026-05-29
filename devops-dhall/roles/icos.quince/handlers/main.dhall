-- Auto-generated from ../../../../devops/roles/icos.quince/handlers/main.yml

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
  , Task::{
      name = Some "restart the quince service",
      systemd = Some {
        name = Some "quince",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "restart rsyslog",
      systemd = Some {
        name = Some "rsyslog",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
