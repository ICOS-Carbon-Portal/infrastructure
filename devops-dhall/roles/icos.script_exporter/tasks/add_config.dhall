-- Auto-generated from ../../../../devops/roles/icos.script_exporter/tasks/add_config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add config to script-exporters config.yaml",
      blockinfile = Some {
        path = "{{ sexp_config }}",
        create = Some False,
        marker = "# {mark} {{ sexp_marker }}",
        block = Some "{{ sexp_block }}",
        insertafter = Some "EOF",
        insertbefore = None Text,
        state = Some "{{ sexp_state | default('present') }}"
    },
      notify = Some [ "reload script-exporter" ]
    }
]
