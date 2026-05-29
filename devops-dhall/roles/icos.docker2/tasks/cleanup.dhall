-- Auto-generated from cleanup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy docker-periodic-cleanup.timer",
      copy = Some {
        src = Some "{{ item }}"
      , dest = "/etc/systemd/system"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "docker-periodic-cleanup.timer", "docker-periodic-cleanup.service" ]
    }
  , Task::{
      name = Some "Start docker-periodic-cleanup.timer",
      systemd = Some {
        name = Some "docker-periodic-cleanup.timer"
      , state = Some "started"
      , daemon_reload = Some True
      , enabled = Some "True"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
