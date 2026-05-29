-- Auto-generated from ../../../../devops/roles/icos.nebula/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload nebula",
      service = Some (Task.Poly_service.Record { name = "nebula", state = "reloaded", enabled = None Bool })
    }
  , Task::{
      name = Some "restart nebula",
      service = Some (Task.Poly_service.Record { name = "nebula", state = "restarted", enabled = None Bool })
    }
  , Task::{
      name = Some "restart systemd-networkd",
      service = Some (Task.Poly_service.Record { name = "systemd-networkd", state = "restarted", enabled = None Bool }),
      notify = Some [ "restart NetworkManager" ]
    }
  , Task::{
      name = Some "restart NetworkManager",
      systemd = Some {
        name = Some "NetworkManager",
        state = Some "restarted",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "reload NetworkManager",
      systemd = Some {
        name = Some "NetworkManager",
        state = Some "reloaded",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "systemd reload",
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
