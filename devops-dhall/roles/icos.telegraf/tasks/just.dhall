-- Auto-generated from ../../../../devops/roles/icos.telegraf/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove /usr/local/bin/icos/telegraf",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/usr/local/bin/icos/telegraf",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Copy justfile",
      template = Some {
        src = "ops-telegraf",
        dest = "/usr/local/bin",
        mode = Some "+x",
        variable_start_string = Some "{{ '{{{' }}",
        variable_end_string = Some "{{ '}}}' }}",
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_justfile"
    }
  , Task::{
      name = Some "Check that the justfile is executable",
      shell = Some "{{ _justfile.dest }}",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
