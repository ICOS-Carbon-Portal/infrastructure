-- Auto-generated from ../../../../devops/roles/icos.rspamd/tasks/pyzor.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "pip install pyzor",
      pip = Some (Task.Poly_pip.Record { name = [ "pyzor" ], virtualenv = None Text, state = Some "present" })
    }
  , Task::{
      name = Some "Check that \"pyzor check\" works",
      shell = Some "echo test | pyzor check",
      changed_when = Some (Task.Poly_changed_when.Bool False),
      register = Some "_r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "not \"public.pyzor.org\" in _r.stdout", "not \"(200, 'OK')\" in _r.stdout" ])
    }
  , Task::{
      name = Some "Create pyzor.socket",
      copy = Some {
        dest = "/etc/systemd/system/pyzor.socket",
        mode = None Text,
        content = Some ''
        [Unit]
        Description=Pyzor socket

        [Socket]
        ListenStream=127.0.0.1:5953
        Accept=yes

        [Install]
        WantedBy=sockets.target

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Create pyzor service",
      copy = Some {
        dest = "/etc/systemd/system/pyzor@.service",
        mode = None Text,
        content = Some ''
        [Unit]
        Description=Pyzor Socket Service
        Requires=pyzor.socket

        [Service]
        Type=simple
        ExecStart=-/usr/local/bin/pyzor check
        StandardInput=socket
        StandardError=journal
        TimeoutStopSec=10

        User=_rspamd
        NoNewPrivileges=true
        PrivateDevices=true
        PrivateTmp=true
        PrivateUsers=true
        ProtectControlGroups=true
        ProtectHome=true
        ProtectKernelModules=true
        ProtectKernelTunables=true
        ProtectSystem=strict

        [Install]
        WantedBy=multi-user.target

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Enable and start pyzor.socket",
      systemd = Some {
        name = Some "pyzor.socket",
        state = Some "started",
        daemon_reload = Some True,
        enabled = Some "True",
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "Create rspamd config for pyzor",
      copy = Some {
        dest = "/etc/rspamd/local.d/external_services.conf",
        mode = None Text,
        content = Some ''
        pyzor {
          # default pyzor settings
          servers = "127.0.0.1:5953"
        }

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
]
