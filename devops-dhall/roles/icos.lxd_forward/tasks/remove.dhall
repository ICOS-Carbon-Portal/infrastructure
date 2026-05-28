-- Auto-generated from remove.yml

let Entry =
    { Type =
        { name : Text
    , lineinfile : Optional ({ path : Text, regex : Text, state : Text })
    , tags : Optional Text
    , iptables_raw : Optional ({ name : Text, table : Text, state : Text })
  }
    , default =
        { lineinfile = None ({ path : Text, regex : Text, state : Text })
    , tags = None Text
    , iptables_raw = None ({ name : Text, table : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Modify /etc/hosts to remove lxd_forward_name.lxd",
      lineinfile = Some {
        path = "/etc/hosts"
      , regex = "(?:.*{{ lxd_forward_name }})\\.lxd$"
      , state = "absent"
    }
    }
  , Entry::{
      name = "Remove iptables rule",
      tags = Some "iptables",
      iptables_raw = Some { name = "forward_ssh_to_{{ lxd_forward_name }}", table = "nat", state = "absent" }
    }
]
