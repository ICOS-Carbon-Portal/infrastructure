-- Auto-generated from ../../../../devops/roles/icos.nextcloud/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy justfile",
      template = Some {
        src = "justfile",
        dest = "{{ nextcloud_home }}",
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
          dest = Some "/usr/local/bin/ops-nextcloud",
          recurse = None Bool,
          src = Some "{{ _justfile.dest }}"
      }),
      register = Some "_symlink"
    }
  , Task::{
      name = Some "Check that the justfile is executable",
      shell = Some "{{ _symlink.dest }}",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
