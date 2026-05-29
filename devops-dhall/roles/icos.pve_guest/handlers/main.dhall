-- Auto-generated from ../../../../devops/roles/icos.pve_guest/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart cron",
      service = Some (Task.Poly_service.Record { name = "cron", state = "restarted", enabled = None Bool }),
      register = Some "_r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "_r.failed", "_r.msg.find('Could not find the requested service cron') < 0" ])
    }
  , Task::{ name = Some "reboot", reboot = Some { reboot_timeout = 120 } }
]
