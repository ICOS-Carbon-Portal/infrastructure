-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload nginx config",
      systemd = Some {
        name = Some "nginx"
      , state = Some "reloaded"
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
