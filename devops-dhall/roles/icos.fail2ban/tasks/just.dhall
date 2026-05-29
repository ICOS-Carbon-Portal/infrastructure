-- Auto-generated from ../../../../devops/roles/icos.fail2ban/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy ops-fail2ban",
      copy = Some {
        dest = "/usr/local/bin/ops-fail2ban",
        mode = Some "+x",
        content = None Text,
        src = Some "ops-fail2ban",
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
