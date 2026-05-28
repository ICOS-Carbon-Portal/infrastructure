-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { template = None ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register = None Text
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Copy ops-zrepl",
      template = Some {
        src = "ops-zrepl"
      , dest = "/usr/local/sbin/"
      , mode = "+x"
      , variable_start_string = "{{ '{{{' }}"
      , variable_end_string = "{{ '}}}' }}"
      , lstrip_blocks = True
    },
      register = Some "_justfile"
    }
  , Task::{
      name = "Check that the justfile is executable",
      shell = Some "{{ _justfile.dest }}",
      changed_when = Some False
    }
]
