-- Auto-generated from ../../../../devops/roles/icos.lxd_forward/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add iptables rule to forward lxd_forward_port",
      tags = Some [ "iptables" ],
      iptables_raw = Some {
        name = "forward_ssh_to_{{ lxd_forward_name }}",
        rules = Some "-A PREROUTING -p tcp --dport {{ lxd_forward_port }} -j DNAT --to-destination {{ lxd_forward_ip }}:22",
        table = Some "nat",
        state = None Text,
        weight = None Natural
    },
      when = Some [ "lxd_forward_port" ]
    }
  , Task::{
      name = Some "Modify /etc/hosts to add lxd_forward_name.lxd",
      lineinfile = Some {
        path = "/etc/hosts",
        regex = Some "(?:^{{ lxd_forward_ip | regex_escape}}.*)|(?:.*{{ lxd_forward_name }})\\.lxd$",
        line = Some "{{ lxd_forward_ip }}\t{{ lxd_forward_name }}.lxd",
        state = Some "present",
        backrefs = None Bool,
        regexp = None Text,
        create = None Bool,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    }
    }
]
