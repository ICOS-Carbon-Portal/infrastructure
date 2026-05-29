-- Auto-generated from ../../../../devops/roles/icos.pve_guest/tasks/terminal.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create  directory",
      file = Some (Task.Poly_file.Record {
          path = Some "/etc/systemd/system/serial-getty@ttyS0.service.d",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      register = Some "_mkdir"
    }
  , Task::{
      name = Some "Create ttyS0 override",
      copy = Some {
        dest = "{{ _mkdir.path }}/autologin.conf",
        mode = None Text,
        content = Some ''
        [Service]
        ExecStart=
        ExecStart=-/sbin/agetty -o '-p -- \\u' --keep-baud 115200,57600,38400,9600 --autologin root - $TERM

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_conf"
    }
  , Task::{
      name = Some "systemd reload",
      systemd = Some {
        name = None Text,
        state = None Text,
        daemon_reload = Some True,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    },
      when = Some [ "_conf.changed" ]
    }
  , Task::{
      name = Some "Add securetty config to pam",
      blockinfile = Some {
        path = "/etc/pam.d/login",
        create = Some True,
        marker = "# {mark} ansible / pve_guest",
        block = Some ''
        auth sufficient pam_listfile.so item=tty sense=allow file=/etc/securetty onerr=fail apply=root

      '',
        insertafter = Some "BOF",
        insertbefore = None Text,
        state = None Text
    }
    }
  , Task::{
      name = Some "Create /etc/securetty",
      copy = Some {
        dest = "/etc/securetty",
        mode = None Text,
        content = Some ''
        ttyS0

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
