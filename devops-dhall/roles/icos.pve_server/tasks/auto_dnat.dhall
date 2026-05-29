-- Auto-generated from ../../../../devops/roles/icos.pve_server/tasks/auto_dnat.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Synchronize icos-auto-dnat source",
      `ansible.posix.synchronize` = Some {
        mode = None Text,
        copy_links = None Bool,
        src = "icos-auto-dnat/",
        dest = "/opt/icos-auto-dnat",
        rsync_opts = Some [ "-F", "--delete-excluded" ],
        owner = Some False,
        group = Some False,
        perms = None Bool,
        delete = None Bool
    },
      register = Some "_rsync"
    }
  , Task::{
      name = Some "Install icos-auto-dnat",
      `community.general.pipx` = Some {
        name = "/opt/icos-auto-dnat/",
        executable = "pipx-global",
        python = Some "python3",
        editable = Some True,
        force = Some "True"
    },
      when = Some [ "_rsync.changed" ],
      register = Some "_pipx",
      changed_when = Some (Task.Poly_changed_when.Texts [
          "_pipx.changed"
        , "_pipx.stdout"
        , "_pipx.stdout.find('already seems to be installed') == -1"
      ])
    }
  , Task::{
      name = Some "Copy auto-dnat service files",
      template = Some {
        src = "{{ item }}",
        dest = "/etc/systemd/system/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "icos-auto-dnat.path", "icos-auto-dnat.timer", "icos-auto-dnat.service" ]),
      register = Some "_systemd"
    }
  , Task::{
      name = Some "Reload systemd",
      systemd = Some {
        name = None Text,
        state = None Text,
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = Some "True",
        status = None Text
    },
      when = Some [ "_systemd.changed" ]
    }
  , Task::{
      name = Some "Start service",
      systemd = Some {
        name = Some "{{ item }}",
        state = Some "{{ 'restarted' if _systemd.changed else 'started' }}",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = None Text,
        status = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "icos-auto-dnat.path", "icos-auto-dnat.timer" ])
    }
]
