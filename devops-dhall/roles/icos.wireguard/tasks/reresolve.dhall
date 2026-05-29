-- Auto-generated from ../../../../devops/roles/icos.wireguard/tasks/reresolve.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create reresolve template service",
      copy = Some {
        dest = "/etc/systemd/system/wg-reresolve@.service",
        mode = None Text,
        content = Some ''
        [Unit]
        Description=Reresolve dns names for wireguard

        [Service]
        Type=oneshot
        ExecStart={{ wireguard_reresolve_script }} %i

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "systemd daemon-reload" ]
    }
  , Task::{
      name = Some "Create reresolve timer",
      copy = Some {
        dest = "/etc/systemd/system/wg-reresolve@.timer",
        mode = None Text,
        content = Some ''
        [Unit]
        Description=Run wireguard reresolve every 30 minutes
        PartOf=wg-quick@%i.service

        [Timer]
        OnCalendar=*-*-* *:0/30

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "systemd daemon-reload" ]
    }
]
