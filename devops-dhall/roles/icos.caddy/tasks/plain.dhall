-- Auto-generated from ../../../../devops/roles/icos.caddy/tasks/plain.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove caddy dropin directory",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "{{ caddy_dropin_path | dirname }}",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      notify = Some [ "restart caddy" ]
    }
  , Task::{
      name = Some "Make /usr/bin/caddy executable",
      file = Some (Task.Poly_file.Record {
          path = Some "/usr/bin/caddy",
          state = None Text,
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "+x",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
]
