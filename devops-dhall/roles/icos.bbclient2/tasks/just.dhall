-- Auto-generated from ../../../../devops/roles/icos.bbclient2/tasks/just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy justfile",
      template = Some {
        src = "justfile",
        dest = "{{ bbclient_home }}/",
        mode = None Text,
        variable_start_string = Some "{{ '{{{{' }}",
        variable_end_string = Some "{{ '}}}}' }}",
        lstrip_blocks = Some True,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Copy systemd-wide justfile",
      copy = Some {
        dest = "/usr/local/bin/",
        mode = Some "+x",
        content = None Text,
        src = Some "ops-bbclient",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
