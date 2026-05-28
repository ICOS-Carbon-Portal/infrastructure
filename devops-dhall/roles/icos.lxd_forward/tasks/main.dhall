-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , tags : Optional Text
    , iptables_raw : Optional ({ name : Text, table : Text, rules : Text })
    , when : Optional Text
    , lineinfile : Optional ({ path : Text, regex : Text, line : Text, state : Text })
  }
    , default =
        { tags = None Text
    , iptables_raw = None ({ name : Text, table : Text, rules : Text })
    , when = None Text
    , lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Add iptables rule to forward lxd_forward_port",
      tags = Some "iptables",
      iptables_raw = Some {
        name = "forward_ssh_to_{{ lxd_forward_name }}"
      , table = "nat"
      , rules = "-A PREROUTING -p tcp --dport {{ lxd_forward_port }} -j DNAT --to-destination {{ lxd_forward_ip }}:22"
    },
      when = Some "lxd_forward_port"
    }
  , Entry::{
      name = "Modify /etc/hosts to add lxd_forward_name.lxd",
      lineinfile = Some {
        path = "/etc/hosts"
      , regex = "(?:^{{ lxd_forward_ip | regex_escape}}.*)|(?:.*{{ lxd_forward_name }})\\.lxd$"
      , line = "{{ lxd_forward_ip }}\t{{ lxd_forward_name }}.lxd"
      , state = "present"
    }
    }
]
