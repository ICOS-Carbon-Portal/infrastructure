-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ name : Text, state : Text })
    , template : Optional ({ src : Text, mode : Text, dest : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { file = None ({ name : Text, state : Text })
    , template = None ({ src : Text, mode : Text, dest : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register = None Text
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Remove old stiltweb justfile",
      file = Some { name = "{{ stiltweb_home }}/justfile", state = "absent" }
    }
  , Task::{
      name = "Copy justfile",
      template = Some {
        src = "justfile"
      , mode = "+x"
      , dest = "/usr/local/bin/icos-stiltweb"
      , variable_start_string = "(("
      , variable_end_string = "))"
      , lstrip_blocks = True
    },
      register = Some "_justfile"
    }
  , Task::{ name = "Check justfile", shell = Some "icos-stiltweb", changed_when = Some False }
]
