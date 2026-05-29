-- Auto-generated from ../../../../devops/roles/icos.nebula/tasks/service.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy nebula.service",
      template = Some {
        src = "nebula.service",
        dest = "/etc/systemd/system",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "restart nebula" ]
    }
  , Task::{
      name = Some "Start nebula service",
      systemd = Some {
        name = Some "nebula",
        state = Some "started",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = Some "True",
        status = None Text
    }
    }
]
