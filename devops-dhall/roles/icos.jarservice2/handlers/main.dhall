-- Auto-generated from ../../../../devops/roles/icos.jarservice2/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart {{ jarservice_name }}",
      service = Some (Task.Poly_service.Record { name = "{{ jarservice_name }}", state = "restarted", enabled = None Bool }),
      when = Some [ "jarservice_state | default('started') == 'started'" ]
    }
  , Task::{
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
