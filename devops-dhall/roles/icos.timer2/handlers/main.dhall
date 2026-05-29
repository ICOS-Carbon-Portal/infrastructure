-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart icos timer",
      systemd = Some {
        name = Some "{{ timer_name }}.timer"
      , state = Some "restarted"
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
