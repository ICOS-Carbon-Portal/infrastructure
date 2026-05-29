-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install iptables-persistent",
      apt = Some {
        name = Some [ "iptables-persistent" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Retrieve server's private key",
      shellfact = Some {
        exec = "cat /etc/wireguard/privatekey"
      , fact = "_privatekey"
      , bool = None Bool
      , list = None Bool
    }
    }
  , Task::{
      name = Some "Install wireguard hub config",
      when = Some [ "wg_hub_ishub" ],
      register = Some "_hub_conf",
      copy = Some {
        src = None Text
      , dest = "/etc/wireguard/{{ wg_hub_intf }}.conf"
      , mode = Some "384"
      , content = Some ''
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
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Install wireguard spoke config",
      when = Some [ "not wg_hub_ishub" ],
      register = Some "_spoke_conf",
      copy = Some {
        src = None Text
      , dest = "/etc/wireguard/{{ wg_hub_intf }}.conf"
      , mode = Some "384"
      , content = Some ''
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
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Add hosts",
      blockinfile = Some {
        marker = "# {mark} cloud.wg_hub {{ wg_hub_config.name }}"
      , state = None Text
      , create = None Bool
      , insertafter = None Text
      , path = "/etc/hosts"
      , block = Some ''
        {% for name, conf in wg_hub_config.peers.items() %}
        {{ conf.addr }} {{ conf.name | default(name) }}.{{ wg_hub_intf }}
        {% if name == wg_hub_peer %}
        {{ conf.addr }} hub.{{ wg_hub_intf }}
        {% endif %}
        {% endfor %}

      ''
      , insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Allow wireguard through firewall",
      when = Some [ "wg_hub_ishub" ],
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}"
      , rules = Some ''
        -A INPUT -p udp --dport {{ wg_hub_port }} -j ACCEPT
        -A FORWARD -i {{ wg_hub_intf }} -j ACCEPT

      ''
      , weight = None Natural
      , table = None Text
      , state = None Text
    }
    }
  , Task::{
      name = Some "Allow all inbound traffic on the wireguard interface",
      iptables_raw = Some {
        name = "wireguard_{{ wg_hub_config.name }}_allow_all"
      , rules = Some ''
        -A INPUT -i {{ wg_hub_intf }} -j ACCEPT

      ''
      , weight = None Natural
      , table = None Text
      , state = Some "{{ 'present' if wg_hub_allow_all else 'absent' }}"
    }
    }
  , Task::{
      name = Some "Setup reresolve dependency",
      when = Some [ "wg_hub_reresolve and not wg_hub_ishub" ],
      command = Some "systemctl add-wants wg-quick@{{ wg_hub_intf }}.service wg-reresolve@{{ wg_hub_intf }}.timer",
      register = Some "_reresolve",
      changed_when = Some "_reresolve.stderr.startswith(\"Created symlink\")"
    }
  , Task::{
      name = Some "Start wg-quick service",
      systemd = Some {
        name = Some "wg-quick@{{ wg_hub_intf }}.service"
      , state = Some "{{ 'restarted' if _hub_conf.changed or _spoke_conf.changed or _reresolve.changed else 'started' }}"
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
  , Task::{
      name = Some "Ping hub",
      command = Some "ping -c 1 -w 10 \"{{ wg_hub_config.hub.peer }}.{{ wg_hub_intf }}\"",
      tags = Some [ "wg_hub_ping" ],
      changed_when = Some "False"
    }
]
