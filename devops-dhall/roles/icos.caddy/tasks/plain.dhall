-- Auto-generated from plain.yml

let Entry =
    { Type =
        { name : Text
    , file : { name : Optional Text, state : Optional Text, path : Optional Text, mode : Optional Text }
    , notify : Optional Text
  }
    , default =
        { notify = None Text
  }
    }

in  [
    Entry::{
      name = "Remove caddy dropin directory",
      file = {
        name = Some "{{ caddy_dropin_path | dirname }}"
      , state = Some "absent"
      , path = None Text
      , mode = None Text
    },
      notify = Some "restart caddy"
    }
  , Entry::{
      name = "Make /usr/bin/caddy executable",
      file = {
        name = None Text
      , state = None Text
      , path = Some "/usr/bin/caddy"
      , mode = Some "+x"
    }
    }
]
