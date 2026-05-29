-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "dnsmasq restart",
      systemd = Some {
        name = Some "{{ dnsmasq_service_name }}"
      , state = Some "restarted"
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
