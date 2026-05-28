-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { template = None ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Copy ops-nebula.justfile",
      template = Some {
        src = "ops-nebula.justfile"
      , dest = "/usr/local/bin/ops-nebula"
      , mode = "+x"
      , variable_start_string = "{{ '{{{' }}"
      , variable_end_string = "{{ '}}}' }}"
      , lstrip_blocks = True
    }
    }
  , Task::{
      name = "Check that ops-nebula is executable",
      shell = Some "ops-nebula",
      changed_when = Some False
    }
]
