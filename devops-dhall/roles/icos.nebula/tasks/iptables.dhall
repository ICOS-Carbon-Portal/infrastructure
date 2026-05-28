-- Auto-generated from iptables.yml

let Item =
    { Type =
        { when : Text
    , block : Optional (List ({ name : Text, apt : Optional ({ name : List Text }), iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }), iptables_raw : Optional ({ name : Text, rules : Text }) }))
    , name : Optional Text
    , debug : Optional ({ msg : Text })
  }
    , default =
        { block = None (List ({ name : Text, apt : Optional ({ name : List Text }), iptables : Optional ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }), iptables_raw : Optional ({ name : Text, rules : Text }) }))
    , name = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = "nebula_fw_enable",
      block = Some [
        {
          name = "Install iptables",
          apt = Some { name = [ "iptables", "iptables-persistent" ] },
          iptables = None ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }),
          iptables_raw = None ({ name : Text, rules : Text })
        }
      , {
          name = "Allow nebula through firewall",
          apt = None ({ name : List Text }),
          iptables = Some {
            state = "absent"
          , chain = "INPUT"
          , protocol = Some "udp"
          , destination_port = Some "{{ nebula_port }}"
          , jump = "ACCEPT"
          , action = None Text
          , in_interface = None Text
        },
          iptables_raw = None ({ name : Text, rules : Text })
        }
      , {
          name = "Allow all traffic on nebula interface",
          apt = None ({ name : List Text }),
          iptables = Some {
            state = "absent"
          , chain = "INPUT"
          , protocol = None Text
          , destination_port = None Text
          , jump = "ACCEPT"
          , action = Some "insert"
          , in_interface = Some "{{ nebula_interface }}"
        },
          iptables_raw = None ({ name : Text, rules : Text })
        }
      , {
          name = "Allow nebula through firewall",
          apt = None ({ name : List Text }),
          iptables = None ({ state : Text, chain : Text, protocol : Optional Text, destination_port : Optional Text, jump : Text, action : Optional Text, in_interface : Optional Text }),
          iptables_raw = Some {
            name = "allow_nebula"
          , rules = ''
            {% if nebula_is_lighthouse %}
            # allow nebula through firewall
            -A INPUT -p udp --dport {{nebula_port}} -j ACCEPT
            {% endif -%}

            # allow all traffic on nebula interface
            -A INPUT -i {{ nebula_interface }} -j ACCEPT

          ''
        }
        }
    ]
    }
  , Item::{
      when = "not nebula_fw_enable",
      name = Some "Display note about manual firewall rules",
      debug = Some {
        msg = ''
        Please manually add the following firewall rules:

          1. Incoming UDP on port {{nebula_port}}
          2. All traffic on interface {{nebula_interface}}

      ''
    }
    }
]
