-- Auto-generated from ../../../../devops/roles/icos.lxd_guest/handlers/main.yml

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
      name = Some "restart cron",
      service = Some (Task.Poly_service.Record { name = "cron", state = "restarted", enabled = None Bool }),
      register = Some "_r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "_r.failed", "_r.msg.find('Could not find the requested service cron') < 0" ])
    }
]
