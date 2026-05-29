-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload nginx config",
      command = Some "nginx -t",
      notify = Some [ "really reload nginx config" ]
    }
  , Task::{
      name = Some "really reload nginx config",
      service = Some { name = "nginx", state = "reloaded", enabled = None Bool }
    }
  , Task::{
      name = Some "reload systemd config",
      systemd = Some {
        name = None Text
      , state = None Text
      , daemon_reload = Some True
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
  , Task::{
      name = Some "restart nginx-prometheus-exporter",
      systemd = Some {
        name = Some "nginx-prometheus-exporter"
      , state = Some "restarted"
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = Some "True"
      , status = None Text
    }
    }
]
