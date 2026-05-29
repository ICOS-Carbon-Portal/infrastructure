-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart nfs-kernel-server",
      systemd = Some {
        name = Some "nfs-kernel-server"
      , state = Some "restarted"
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = Some "True"
      , status = None Text
    }
    }
]
