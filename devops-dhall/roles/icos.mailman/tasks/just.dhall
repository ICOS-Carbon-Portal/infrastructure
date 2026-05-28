-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ name : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , template : Optional ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { file = None ({ name : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , template = None ({ src : Text, dest : Text, mode : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , register = None Text
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Remove Makefile",
      file = Some {
        name = Some "{{ mailman_home }}/Makefile"
      , state = "absent"
      , dest = None Text
      , src = None Text
    }
    }
  , Task::{
      name = "Copy justfile",
      template = Some {
        src = "justfile"
      , dest = "{{ mailman_home }}/justfile"
      , mode = "+x"
      , variable_start_string = "(("
      , variable_end_string = "))"
      , lstrip_blocks = True
    },
      register = Some "_justfile"
    }
  , Task::{
      name = "Create executable symlink to justfile",
      file = Some {
        name = None Text
      , state = "link"
      , dest = Some "/usr/local/bin/icos-mailman"
      , src = Some "{{ _justfile.dest }}"
    },
      register = Some "_symlink"
    }
  , Task::{
      name = "Check that the mailman justfile is executable",
      shell = Some "{{ _symlink.dest }}",
      changed_when = Some False
    }
]
