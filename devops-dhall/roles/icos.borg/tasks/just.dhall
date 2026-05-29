-- Auto-generated from ../../../../devops/roles/icos.borg/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy ops-borg",
      copy = Some {
        dest = "/usr/local/bin/ops-borg",
        mode = Some "+x",
        content = None Text,
        src = Some "ops-borg",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_justfile"
    }
  , Task::{
      name = Some "Check that the justfile is executable",
      shell = Some "{{ _justfile.dest }}",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
