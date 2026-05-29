-- Auto-generated from ../../../../devops/roles/icos.bbclient2/tasks/scripts.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create bin directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ bbclient_bin_dir }}",
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
      name = Some "Install borg wrapper that contains our ssh info",
      copy = Some {
        dest = "{{ bbclient_wrapper }}",
        mode = Some "+x",
        content = Some ''
        #!/bin/bash
        export BORG_RSH="{{ bbclient_ssh_bin }}"
        export BORG_BASE_DIR="{{ bbclient_borg_dir }}"
        exec {{ borg_bin }} "$@"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Create helper scripts",
      template = Some {
        src = "{{ item }}",
        dest = "{{ bbclient_bin_dir }}",
        mode = Some "+x",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "bbclient", "bbclient-all" ])
    }
]
