-- Auto-generated from absent.yml

let Entry =
    { Type =
        { name : Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , loop : Optional (List Text)
    , file : Optional ({ dest : Text, state : Text })
    , systemd : Optional ({ name : Text, state : Text })
    , changed_when : Optional Bool
  }
    , default =
        { fail = None ({ msg : Text })
    , when = None Text
    , loop = None (List Text)
    , file = None ({ dest : Text, state : Text })
    , systemd = None ({ name : Text, state : Text })
    , changed_when = None Bool
  }
    }

in  [
    Entry::{
      name = "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [ "nginxsite_name" ]
    }
  , Entry::{
      name = "Remove config file",
      loop = Some [
        "{{ nginxsite_path_enable }}"
      , "{{ nginxsite_path_available }}"
      , "{{ nginxsite_path_confd }}"
    ],
      file = Some { dest = "{{ item }}", state = "absent" }
    }
  , Entry::{
      name = "Reload nginx",
      systemd = Some { name = "nginx", state = "reloaded" },
      changed_when = Some False
    }
]
