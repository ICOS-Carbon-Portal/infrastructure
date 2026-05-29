-- Auto-generated from resolve-networkd.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add nebula dns server",
      copy = Some {
        src = None Text
      , dest = "/etc/systemd/network/{{ nebula_interface }}.network"
      , mode = None Text
      , content = Some ''
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
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "restart systemd-networkd" ]
    }
  , Task::{
      name = Some "Create drop-in directory",
      file = Some {
        path = Some "/etc/systemd/system/nebula.service.d"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Create drop-in configuration",
      copy = Some {
        src = None Text
      , dest = "/etc/systemd/system/nebula.service.d/restart-networkd.conf"
      , mode = None Text
      , content = Some ''
        [Service]
        # When nebula is restarted, systemd-networkd will lose the
        # nebula-specific name servers configured in
        # /etc/systemd/network/nebula.network. Restarting systemd-networkd
        # will fix it. A better fix would be highly desired.
        ExecStartPost=/bin/sh -c 'sleep 1; systemctl restart systemd-networkd'

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "systemd reload" ]
    }
]
