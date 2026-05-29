-- Auto-generated from systemd.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy systemd service files",
      template = Some {
        src = "{{ item }}"
      , dest = "/etc/systemd/system"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = Some True
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      loop = Some [ "restic-server.service", "restic-server.socket" ],
      notify = Some [ "restart restic" ]
    }
  , Task::{
      name = Some "Start restic socket",
      systemd = Some {
        name = Some "restic-server.socket"
      , state = Some "started"
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
