-- Auto-generated from pyzor.yml

let Task =
    { Type =
        { name : Text
    , pip : Optional ({ name : Text, state : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , failed_when : Optional (List Text)
    , copy : Optional ({ dest : Text, content : Text })
    , systemd : Optional ({ name : Text, state : Text, enabled : Bool, daemon_reload : Bool })
    , notify : Optional Text
  }
    , default =
        { pip = None ({ name : Text, state : Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None (List Text)
    , copy = None ({ dest : Text, content : Text })
    , systemd = None ({ name : Text, state : Text, enabled : Bool, daemon_reload : Bool })
    , notify = None Text
  }
    }

in  [
    Task::{ name = "pip install pyzor", pip = Some { name = "pyzor", state = "present" } }
  , Task::{
      name = "Check that \"pyzor check\" works",
      shell = Some "echo test | pyzor check",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some [ "not \"public.pyzor.org\" in _r.stdout", "not \"(200, 'OK')\" in _r.stdout" ]
    }
  , Task::{
      name = "Create pyzor.socket",
      copy = Some {
        dest = "/etc/systemd/system/pyzor.socket"
      , content = ''
        [Unit]
        Description=Pyzor socket

        [Socket]
        ListenStream=127.0.0.1:5953
        Accept=yes

        [Install]
        WantedBy=sockets.target

      ''
    }
    }
  , Task::{
      name = "Create pyzor service",
      copy = Some {
        dest = "/etc/systemd/system/pyzor@.service"
      , content = ''
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

      ''
    }
    }
  , Task::{
      name = "Enable and start pyzor.socket",
      systemd = Some {
        name = "pyzor.socket"
      , state = "started"
      , enabled = True
      , daemon_reload = True
    }
    }
  , Task::{
      name = "Create rspamd config for pyzor",
      copy = Some {
        dest = "/etc/rspamd/local.d/external_services.conf"
      , content = ''
        pyzor {
          # default pyzor settings
          servers = "127.0.0.1:5953"
        }

      ''
    },
      notify = Some "restart rspamd"
    }
]
