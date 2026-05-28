-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text })
    , sysctl : Optional ({ name : Text, value : Text })
    , iptables_raw : Optional ({ name : Text, weight : Optional Natural, rules : Text })
  }
    , default =
        { apt = None ({ name : Text })
    , sysctl = None ({ name : Text, value : Text })
    , iptables_raw = None ({ name : Text, weight : Optional Natural, rules : Text })
  }
    }

in  [
    Task::{
      name = "Install the iptables-persistent package",
      apt = Some { name = "iptables-persistent" }
    }
  , Task::{
      name = "Set IP forwarding",
      sysctl = Some { name = "net.ipv4.ip_forward", value = "{{ iptables_forward | int }}" }
    }
  , Task::{
      name = "Setup default iptables rules",
      iptables_raw = Some {
        name = "iptables_default"
      , weight = Some 10
      , rules = ''
        # allow all on loopback
        -A INPUT -i lo -j ACCEPT
        -A OUTPUT -o lo -j ACCEPT

        # allow all established connections
        -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        # drop invalid connections
        -A INPUT -m conntrack --ctstate INVALID -j DROP

        # icmp codes for INPUT
        -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
        -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
        -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
        -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

        # icmp code for FORWARD
        -A FORWARD -p icmp --icmp-type destination-unreachable -j ACCEPT
        -A FORWARD -p icmp --icmp-type time-exceeded -j ACCEPT
        -A FORWARD -p icmp --icmp-type parameter-problem -j ACCEPT
        -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT

        {% if iptables_mdns -%}
        # Multicast mDNS for service discovery
        -A INPUT -p udp -d 224.0.0.251 --dport 5353 -j ACCEPT
        {% endif %}
        {% if iptables_upnp %}
        # Multicast UPnP for service discovery
        -A INPUT -p udp -d 239.255.255.250 --dport 1900 -j ACCEPT
        {% endif -%}

        # policy
        -P INPUT DROP
        -P OUTPUT ACCEPT
        -P FORWARD DROP

      ''
    }
    }
  , Task::{
      name = "Allow ssh through firewall",
      iptables_raw = Some {
        name = "allow_ssh"
      , weight = None Natural
      , rules = "-A INPUT -p tcp --dport {{ iptables_ssh_port }} -j ACCEPT -m comment --comment 'ssh'"
    }
    }
]
