-- Auto-generated from remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Modify /etc/hosts to remove lxd_forward_name.lxd",
      lineinfile = Some {
        path = "/etc/hosts"
      , line = None Text
      , state = Some "absent"
      , regex = Some "(?:.*{{ lxd_forward_name }})\\.lxd$"
      , regexp = None Text
      , create = None Bool
      , owner = None Text
      , group = None Text
      , insertafter = None Text
      , mode = None Natural
      , insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Remove iptables rule",
      tags = Some [ "iptables" ],
      iptables_raw = Some {
        name = "forward_ssh_to_{{ lxd_forward_name }}"
      , rules = None Text
      , weight = None Natural
      , table = Some "nat"
      , state = Some "absent"
    }
    }
]
