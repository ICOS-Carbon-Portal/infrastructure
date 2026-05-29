-- Auto-generated from remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Stop and disable wg-quick",
      systemd = Some {
        name = Some "wg-quick@{{ wg_hub_intf }}.service"
      , state = Some "stopped"
      , daemon_reload = None Bool
      , enabled = Some "False"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
  , Task::{
      name = Some "Remove - \"Allow all inbound traffic on the wireguard interface\"",
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}_allow_all"
      , rules = None Text
      , weight = None Natural
      , table = None Text
      , state = Some "absent"
    }
    }
  , Task::{
      name = Some "Remove - Allow wireguard through firewall",
      when = Some [ "wg_hub_ishub" ],
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}"
      , rules = None Text
      , weight = None Natural
      , table = None Text
      , state = Some "absent"
    }
    }
  , Task::{
      name = Some "Remove hosts",
      blockinfile = Some {
        marker = "# {mark} cloud.wg_hub {{ wg_hub_config.name }}"
      , state = Some "absent"
      , create = None Bool
      , insertafter = None Text
      , path = "/etc/hosts"
      , block = None Text
      , insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Remove wireguard config",
      file = Some {
        path = Some "/etc/wireguard/{{ wg_hub_intf }}.conf"
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
]
