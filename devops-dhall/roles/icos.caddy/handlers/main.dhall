-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "restart caddy",
      systemd = Some {
        name = Some "caddy"
      , state = Some "restarted"
      , daemon_reload = Some True
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
  , Task::{
      name = Some "reload caddy",
      shell = Some "{{ caddy_bin }} reload --config /etc/caddy/Caddyfile --adapter caddyfile",
      changed_when = Some "False"
    }
]
