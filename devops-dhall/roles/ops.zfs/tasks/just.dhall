-- Auto-generated from just.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy ops-zfs",
      copy = Some {
        src = Some "ops-zfs"
      , dest = "/usr/local/bin/ops-zfs"
      , mode = Some "+x"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      register = Some "_justfile"
    }
  , Task::{
      name = Some "Check that the justfile is executable",
      shell = Some "{{ _justfile.dest }}",
      changed_when = Some "False"
    }
]
