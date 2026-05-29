-- Auto-generated from ../../../../devops/roles/icos.lxd_forward/tasks/remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Modify /etc/hosts to remove lxd_forward_name.lxd",
      lineinfile = Some {
        path = "/etc/hosts",
        regex = Some "(?:.*{{ lxd_forward_name }})\\.lxd$",
        line = None Text,
        state = Some "absent",
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
  , Task::{
      name = Some "Remove iptables rule",
      tags = Some [ "iptables" ],
      iptables_raw = Some {
        name = "forward_ssh_to_{{ lxd_forward_name }}",
        rules = None Text,
        table = Some "nat",
        state = Some "absent",
        weight = None Natural
    }
    }
]
