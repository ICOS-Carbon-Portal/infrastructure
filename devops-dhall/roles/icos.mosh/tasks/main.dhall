-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , iptables_raw : Optional ({ name : Text, rules : Text })
    , when : Optional Text
  }
    , default =
        { apt = None ({ name : List Text })
    , iptables_raw = None ({ name : Text, rules : Text })
    , when = None Text
  }
    }

in  [
    Task::{ name = "Install mosh", apt = Some { name = [ "mosh" ] } }
  , Task::{
      name = "Allow mosh through firewall",
      iptables_raw = Some {
        name = "allow_mosh"
      , rules = "-A INPUT -p udp -m multiport --dports 60000:61000 -j ACCEPT -m comment --comment 'mosh'"
    },
      when = Some "mosh_add_firewall"
    }
]
