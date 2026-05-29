-- Auto-generated from just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove Makefile",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "{{ mailman_home }}/Makefile"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Copy justfile",
      template = Some {
        src = "justfile"
      , dest = "{{ mailman_home }}/justfile"
      , mode = Some "+x"
      , variable_start_string = Some "(("
      , variable_end_string = Some "))"
      , lstrip_blocks = Some True
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      register = Some "_justfile"
    }
  , Task::{
      name = Some "Create executable symlink to justfile",
      file = Some {
        path = None Text
      , state = Some "link"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "/usr/local/bin/icos-mailman"
      , recurse = None Bool
      , src = Some "{{ _justfile.dest }}"
    },
      register = Some "_symlink"
    }
  , Task::{
      name = Some "Check that the mailman justfile is executable",
      shell = Some "{{ _symlink.dest }}",
      changed_when = Some "False"
    }
]
