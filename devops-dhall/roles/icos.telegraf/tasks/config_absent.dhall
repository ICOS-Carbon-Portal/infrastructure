-- Auto-generated from config_absent.yml

let Entry =
    { Type =
        { name : Text
    , fail : Optional ({ msg : Text })
    , when : Optional (List Text)
    , file : Optional ({ name : Text, state : Text })
    , notify : Optional Text
  }
    , default =
        { fail = None ({ msg : Text })
    , when = None (List Text)
    , file = None ({ name : Text, state : Text })
    , notify = None Text
  }
    }

in  [
    Entry::{
      name = "Fail if user is trying to remove main config file",
      fail = Some { msg = "Refusing to remove main config file." },
      when = Some [ "telegraf_config_file == \"telegraf.conf\"" ]
    }
  , Entry::{
      name = "Remove telegraf config file",
      file = Some {
        name = "{{ telegraf_config_root }}/{{ telegraf_config_file }}"
      , state = "absent"
    },
      notify = Some "reload telegraf"
    }
]
