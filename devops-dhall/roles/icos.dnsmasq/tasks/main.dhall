-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "dnsmasq_setup" ] }
  , Task::{ import_tasks = Some "config.yml", tags = Some [ "dnsmasq_config" ] }
  , Task::{ import_tasks = Some "hosts.yml", tags = Some [ "dnsmasq_hosts" ] }
  , Task::{
      name = Some "Start and enable dnsmasq",
      systemd = Some {
        name = Some "{{ dnsmasq_service_name }}"
      , state = None Text
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
