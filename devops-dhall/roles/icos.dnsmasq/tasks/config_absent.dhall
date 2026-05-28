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
      fail = Some { msg = "We're not setup to remove the default config file." },
      when = Some [ "dnsmasq_config_name == \"config\"" ]
    }
  , Entry::{
      name = "Remove dnsmasq config file",
      file = Some { name = "{{ dnsmasq_config_file }}", state = "absent" },
      notify = Some "dnsmasq restart"
    }
]
