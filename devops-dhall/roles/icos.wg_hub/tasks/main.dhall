-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text })
    , shellfact : Optional ({ exec : Text, fact : Text })
    , when : Optional Text
    , register : Optional Text
    , copy : Optional ({ dest : Text, mode : Natural, content : Text })
    , blockinfile : Optional ({ marker : Text, path : Text, block : Text })
    , iptables_raw : Optional ({ name : Text, rules : Text, state : Optional Text })
    , command : Optional Text
    , changed_when : Optional Text
    , systemd : Optional ({ name : Text, state : Text, enabled : Bool })
    , tags : Optional Text
  }
    , default =
        { apt = None ({ name : Text })
    , shellfact = None ({ exec : Text, fact : Text })
    , when = None Text
    , register = None Text
    , copy = None ({ dest : Text, mode : Natural, content : Text })
    , blockinfile = None ({ marker : Text, path : Text, block : Text })
    , iptables_raw = None ({ name : Text, rules : Text, state : Optional Text })
    , command = None Text
    , changed_when = None Text
    , systemd = None ({ name : Text, state : Text, enabled : Bool })
    , tags = None Text
  }
    }

in  [
    Task::{ name = "Install iptables-persistent", apt = Some { name = "iptables-persistent" } }
  , Task::{
      name = "Retrieve server's private key",
      shellfact = Some { exec = "cat /etc/wireguard/privatekey", fact = "_privatekey" }
    }
  , Task::{
      name = "Install wireguard hub config",
      when = Some "wg_hub_ishub",
      register = Some "_hub_conf",
      copy = Some {
        dest = "/etc/wireguard/{{ wg_hub_intf }}.conf"
      , mode = 384
      , content = ''
        [Interface]
        Address = {{ wg_hub_self.addr }}
        ListenPort = {{ wg_hub_config.hub.port }}
        PrivateKey = {{ _privatekey }}

        {% for name, conf in wg_hub_config.peers.items() %}
        {% if name != inventory_hostname %}
        # {{ name }}
        [Peer]
        PublicKey = {{ conf.key | default(lookup('file', '%s/%s' % (wg_hub_key_dir, name))) }}
        AllowedIPs = {{ conf.allowed_ips | default("%s/32" % conf.addr) }}
        PersistentKeepalive = 25
        {% endif %}

        {% endfor %}

      ''
    }
    }
  , Task::{
      name = "Install wireguard spoke config",
      when = Some "not wg_hub_ishub",
      register = Some "_spoke_conf",
      copy = Some {
        dest = "/etc/wireguard/{{ wg_hub_intf }}.conf"
      , mode = 384
      , content = ''
        [Interface]
        Address = {{ wg_hub_self.addr }}
        {% if wg_hub_self.port is defined %}
        ListenPort =  {{ wg_hub_self.port }}
        {% endif %}
        PrivateKey = {{ _privatekey }}

        # {{ wg_hub_peer }}
        [Peer]
        PublicKey = {{ wg_hub_key }}
        Endpoint = {{ wg_hub_addr -}}:{{ wg_hub_config.hub.port }}
        AllowedIPs = {{ wg_hub_config.allowed_ips }}
        PersistentKeepalive = 25

      ''
    }
    }
  , Task::{
      name = "Add hosts",
      blockinfile = Some {
        marker = "# {mark} cloud.wg_hub {{ wg_hub_config.name }}"
      , path = "/etc/hosts"
      , block = ''
        {% for name, conf in wg_hub_config.peers.items() %}
        {{ conf.addr }} {{ conf.name | default(name) }}.{{ wg_hub_intf }}
        {% if name == wg_hub_peer %}
        {{ conf.addr }} hub.{{ wg_hub_intf }}
        {% endif %}
        {% endfor %}

      ''
    }
    }
  , Task::{
      name = "Allow wireguard through firewall",
      when = Some "wg_hub_ishub",
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}"
      , rules = ''
        -A INPUT -p udp --dport {{ wg_hub_port }} -j ACCEPT
        -A FORWARD -i {{ wg_hub_intf }} -j ACCEPT

      ''
      , state = None Text
    }
    }
  , Task::{
      name = "Allow all inbound traffic on the wireguard interface",
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}_allow_all"
      , rules = ''
        -A INPUT -i {{ wg_hub_intf }} -j ACCEPT

      ''
      , state = Some "{{ 'present' if wg_hub_allow_all else 'absent' }}"
    }
    }
  , Task::{
      name = "Setup reresolve dependency",
      when = Some "wg_hub_reresolve and not wg_hub_ishub",
      register = Some "_reresolve",
      command = Some "systemctl add-wants wg-quick@{{ wg_hub_intf }}.service wg-reresolve@{{ wg_hub_intf }}.timer",
      changed_when = Some "_reresolve.stderr.startswith(\"Created symlink\")"
    }
  , Task::{
      name = "Start wg-quick service",
      systemd = Some {
        name = "wg-quick@{{ wg_hub_intf }}.service"
      , state = "{{ 'restarted' if _hub_conf.changed or _spoke_conf.changed or _reresolve.changed else 'started' }}"
      , enabled = True
    }
    }
  , Task::{
      name = "Ping hub",
      command = Some "ping -c 1 -w 10 \"{{ wg_hub_config.hub.peer }}.{{ wg_hub_intf }}\"",
      changed_when = Some "False",
      tags = Some "wg_hub_ping"
    }
]
