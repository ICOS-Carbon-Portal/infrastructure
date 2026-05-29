-- Auto-generated from ../../../../devops/roles/icos.wg_hub/tasks/remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Stop and disable wg-quick",
      systemd = Some {
        name = Some "wg-quick@{{ wg_hub_intf }}.service",
        state = Some "stopped",
        daemon_reload = None Bool,
        enabled = Some "False",
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "Remove - \"Allow all inbound traffic on the wireguard interface\"",
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}_allow_all",
        rules = None Text,
        table = None Text,
        state = Some "absent",
        weight = None Natural
    }
    }
  , Task::{
      name = Some "Remove - Allow wireguard through firewall",
      when = Some [ "wg_hub_ishub" ],
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}",
        rules = None Text,
        table = None Text,
        state = Some "absent",
        weight = None Natural
    }
    }
  , Task::{
      name = Some "Remove hosts",
      blockinfile = Some {
        path = "/etc/hosts",
        create = None Bool,
        marker = "# {mark} cloud.wg_hub {{ wg_hub_config.name }}",
        block = None Text,
        insertafter = None Text,
        insertbefore = None Text,
        state = Some "absent"
    }
    }
  , Task::{
      name = Some "Remove wireguard config",
      file = Some (Task.Poly_file.Record {
          path = Some "/etc/wireguard/{{ wg_hub_intf }}.conf",
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
]
