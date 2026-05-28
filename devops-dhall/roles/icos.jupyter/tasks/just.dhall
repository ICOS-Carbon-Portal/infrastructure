-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register : Optional Text
    , file : Optional ({ dest : Text, src : Text, state : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { template = None ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register = None Text
    , file = None ({ dest : Text, src : Text, state : Text })
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Copy justfile",
      template = Some {
        src = "justfile"
      , dest = "{{ jupyter_home }}"
      , mode = "+x"
      , variable_start_string = "(("
      , variable_end_string = "))"
      , lstrip_blocks = True
    },
      register = Some "_justfile"
    }
  , Task::{
      name = "Create executable symlink to justfile",
      register = Some "_symlink",
      file = Some {
        dest = "/usr/local/bin/ops-jupyter"
      , src = "{{ _justfile.dest }}"
      , state = "link"
    }
    }
  , Task::{
      name = "Check that the justfile is executable",
      shell = Some "{{ _symlink.dest }}",
      changed_when = Some False
    }
]
