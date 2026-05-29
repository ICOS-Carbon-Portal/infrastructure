-- Auto-generated from add_config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add config to script-exporters config.yaml",
      blockinfile = Some {
        marker = "# {mark} {{ sexp_marker }}"
      , state = Some "{{ sexp_state | default('present') }}"
      , create = Some False
      , insertafter = Some "EOF"
      , path = "{{ sexp_config }}"
      , block = Some "{{ sexp_block }}"
      , insertbefore = None Text
    },
      notify = Some [ "reload script-exporter" ]
    }
]
