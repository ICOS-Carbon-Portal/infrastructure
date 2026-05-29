-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart restic",
      systemd = Some {
        name = Some "restic-server.socket"
      , state = Some "restarted"
      , daemon_reload = Some True
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
