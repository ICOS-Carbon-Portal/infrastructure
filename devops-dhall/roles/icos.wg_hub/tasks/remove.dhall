-- Auto-generated from remove.yml

let Entry =
    { Type =
        { name : Text
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text })
    , iptables_raw : Optional ({ name : Text, state : Text })
    , when : Optional Text
    , blockinfile : Optional ({ marker : Text, path : Text, state : Text })
    , file : Optional ({ path : Text, state : Text })
  }
    , default =
        { systemd = None ({ name : Text, enabled : Bool, state : Text })
    , iptables_raw = None ({ name : Text, state : Text })
    , when = None Text
    , blockinfile = None ({ marker : Text, path : Text, state : Text })
    , file = None ({ path : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Stop and disable wg-quick",
      systemd = Some { name = "wg-quick@{{ wg_hub_intf }}.service", enabled = False, state = "stopped" }
    }
  , Entry::{
      name = "Remove - \"Allow all inbound traffic on the wireguard interface\"",
      iptables_raw = Some { name = "wireguard_{{ wg_hub_config.name }}_allow_all", state = "absent" }
    }
  , Entry::{
      name = "Remove - Allow wireguard through firewall",
      iptables_raw = Some { name = "wireguard_{{ wg_hub_config.name }}", state = "absent" },
      when = Some "wg_hub_ishub"
    }
  , Entry::{
      name = "Remove hosts",
      blockinfile = Some {
        marker = "# {mark} cloud.wg_hub {{ wg_hub_config.name }}"
      , path = "/etc/hosts"
      , state = "absent"
    }
    }
  , Entry::{
      name = "Remove wireguard config",
      file = Some { path = "/etc/wireguard/{{ wg_hub_intf }}.conf", state = "absent" }
    }
]
