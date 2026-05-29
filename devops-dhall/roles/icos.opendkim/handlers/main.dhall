-- Auto-generated from ../../../../devops/roles/icos.opendkim/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Restart opendkim",
      systemd = Some {
        name = Some "opendkim",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "Restart postfix",
      systemd = Some {
        name = Some "postfix",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
