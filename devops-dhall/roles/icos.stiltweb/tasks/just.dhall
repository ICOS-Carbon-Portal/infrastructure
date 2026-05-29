-- Auto-generated from ../../../../devops/roles/icos.stiltweb/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove old stiltweb justfile",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "{{ stiltweb_home }}/justfile",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Copy justfile",
      template = Some {
        src = "justfile",
        dest = "/usr/local/bin/icos-stiltweb",
        mode = Some "+x",
        variable_start_string = Some "((",
        variable_end_string = Some "))",
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_justfile"
    }
  , Task::{
      name = Some "Check justfile",
      shell = Some "icos-stiltweb",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
