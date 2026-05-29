-- Auto-generated from ../../../../devops/roles/icos.rspamd/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart rspamd",
      systemd = Some {
        name = Some "rspamd",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
