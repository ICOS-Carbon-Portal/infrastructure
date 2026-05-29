-- Auto-generated from ../../../../devops/roles/icos.mailman/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove Makefile",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "{{ mailman_home }}/Makefile",
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
        dest = "{{ mailman_home }}/justfile",
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
      name = Some "Create executable symlink to justfile",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "/usr/local/bin/icos-mailman",
          recurse = None Bool,
          src = Some "{{ _justfile.dest }}"
      }),
      register = Some "_symlink"
    }
  , Task::{
      name = Some "Check that the mailman justfile is executable",
      shell = Some "{{ _symlink.dest }}",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
