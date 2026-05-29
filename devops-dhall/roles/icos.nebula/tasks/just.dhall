-- Auto-generated from just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy ops-nebula.justfile",
      template = Some {
        src = "ops-nebula.justfile"
      , dest = "/usr/local/bin/ops-nebula"
      , mode = Some "+x"
      , variable_start_string = Some "{{ '{{{' }}"
      , variable_end_string = Some "{{ '}}}' }}"
      , lstrip_blocks = Some True
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    }
    }
  , Task::{
      name = Some "Check that ops-nebula is executable",
      shell = Some "ops-nebula",
      changed_when = Some "False"
    }
]
