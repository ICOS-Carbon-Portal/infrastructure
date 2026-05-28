-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , systemd : Optional ({ name : Text, state : Text, daemon_reload : Bool })
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { systemd = None ({ name : Text, state : Text, daemon_reload : Bool })
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "restart caddy",
      systemd = Some { name = "caddy", state = "restarted", daemon_reload = True }
    }
  , Task::{
      name = "reload caddy",
      shell = Some "{{ caddy_bin }} reload --config /etc/caddy/Caddyfile --adapter caddyfile",
      changed_when = Some False
    }
]
