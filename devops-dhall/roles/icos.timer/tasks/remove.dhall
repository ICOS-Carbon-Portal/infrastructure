-- Auto-generated from remove.yml

let Entry =
    { Type =
        { name : Text
    , command : Optional Text
    , register : Optional Text
    , changed_when : Optional Bool
    , failed_when : Optional (List Text)
    , when : Optional Text
    , file : Optional ({ path : Text, state : Text })
  }
    , default =
        { command = None Text
    , register = None Text
    , changed_when = None Bool
    , failed_when = None (List Text)
    , when = None Text
    , file = None ({ path : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Stop and disable timer",
      command = Some "systemctl disable --now {{ timer_name }}.timer",
      register = Some "r",
      changed_when = Some False,
      failed_when = Some [ "r.rc != 0", "not r.stderr.endswith('does not exist.')" ]
    }
  , Entry::{
      name = "Remove home directory",
      when = Some "timer_home != \"/etc/systemd/systemd\"",
      file = Some { path = "{{ timer_home }}", state = "absent" }
    }
]
