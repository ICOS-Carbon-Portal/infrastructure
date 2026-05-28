-- Auto-generated from resolve-networkd.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , notify : Optional Text
    , file : Optional ({ path : Text, state : Text })
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , notify = None Text
    , file = None ({ path : Text, state : Text })
  }
    }

in  [
    Task::{
      name = "Add nebula dns server",
      copy = Some {
        dest = "/etc/systemd/network/{{ nebula_interface }}.network"
      , content = ''
        # This file is read by both systemd-networkd and systemd-resolved. The
        # trick is to configure systemd-resolved to add a specific dns server
        # for the nebula link while keeping systemd-networkd from messing things
        # up.

        [Match]
        Name={{ nebula_interface }}

        [Network]
        {% for host in nebula_resolve_servers %}
        DNS={{ host }}%{{ nebula_interface }}
        {% endfor %}
        Domains=~{{ nebula_domain }}

        # Keeps systemd-networkd from clobbering the ip set by nebula
        KeepConfiguration=static

      ''
    },
      notify = Some "restart systemd-networkd"
    }
  , Task::{
      name = "Create drop-in directory",
      file = Some { path = "/etc/systemd/system/nebula.service.d", state = "directory" }
    }
  , Task::{
      name = "Create drop-in configuration",
      copy = Some {
        dest = "/etc/systemd/system/nebula.service.d/restart-networkd.conf"
      , content = ''
        [Service]
        # When nebula is restarted, systemd-networkd will lose the
        # nebula-specific name servers configured in
        # /etc/systemd/network/nebula.network. Restarting systemd-networkd
        # will fix it. A better fix would be highly desired.
        ExecStartPost=/bin/sh -c 'sleep 1; systemctl restart systemd-networkd'

      ''
    },
      notify = Some "systemd reload"
    }
]
