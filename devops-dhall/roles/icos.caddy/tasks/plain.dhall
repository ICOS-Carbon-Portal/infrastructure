-- Auto-generated from plain.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove caddy dropin directory",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "{{ caddy_dropin_path | dirname }}"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      notify = Some [ "restart caddy" ]
    }
  , Task::{
      name = Some "Make /usr/bin/caddy executable",
      file = Some {
        path = Some "/usr/bin/caddy"
      , state = None Text
      , mode = Some "+x"
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
]
