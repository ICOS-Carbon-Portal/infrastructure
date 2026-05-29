-- Auto-generated from ../../../../devops/roles/icos.zrepl/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy ops-zrepl",
      template = Some {
        src = "ops-zrepl",
        dest = "/usr/local/sbin/",
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
