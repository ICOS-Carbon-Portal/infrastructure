-- Auto-generated from ../../../../devops/roles/icos.caddy/tasks/xcaddy.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_role = Some (Task.Poly_import_role.Str "name=icos.xcaddy") }
  , Task::{
      name = Some "Compile caddy using xcaddy",
      command = Some "xcaddy build --output {{ caddy_via_xcaddy }} {% for module in caddy_modules %} --with {{ module }} {% endfor %}",
      args = Some {
        chdir = Some "/tmp",
        creates = Some "{{ caddy_via_xcaddy }}",
        executable = None Text,
        removes = None Text
    },
      notify = Some [ "restart caddy" ]
    }
  , Task::{
      name = Some "Create caddy systemd drop-in directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ caddy_dropin_path | dirname }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Create caddy systemd drop-in file",
      copy = Some {
        dest = "{{ caddy_dropin_path }}",
        mode = None Text,
        content = Some ''
        [Service]
        ExecStart=
        ExecStart={{ caddy_via_xcaddy }} run --environ --config /etc/caddy/Caddyfile
        ExecReload=
        ExecReload={{ caddy_via_xcaddy }} reload --config /etc/caddy/Caddyfile --force

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart caddy" ]
    }
  , Task::{
      name = Some "Make /usr/bin/caddy non-executable to avoid confusion",
      file = Some (Task.Poly_file.Record {
          path = Some "/usr/bin/caddy",
          state = None Text,
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "-x",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
]
