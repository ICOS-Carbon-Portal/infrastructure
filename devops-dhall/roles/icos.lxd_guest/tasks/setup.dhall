-- Auto-generated from setup.yml

let Item =
    { Type =
        { name : Optional Text
    , apt : Optional ({ update_cache : Bool, name : List Text })
    , timezone : Optional ({ name : Text })
    , notify : Optional Text
    , locale_gen : Optional ({ name : Text, state : Text })
    , loop : Optional (List Text)
    , authorized_key : Optional ({ user : Text, state : Text, key : Text, exclusive : Bool })
    , when : Optional Text
    , lineinfile : Optional ({ path : Text, line : Text, regex : Text, state : Text })
    , import_role : Optional Text
  }
    , default =
        { name = None Text
    , apt = None ({ update_cache : Bool, name : List Text })
    , timezone = None ({ name : Text })
    , notify = None Text
    , locale_gen = None ({ name : Text, state : Text })
    , loop = None (List Text)
    , authorized_key = None ({ user : Text, state : Text, key : Text, exclusive : Bool })
    , when = None Text
    , lineinfile = None ({ path : Text, line : Text, regex : Text, state : Text })
    , import_role = None Text
  }
    }

in  [
    Item::{
      name = Some "Install packages",
      apt = Some { update_cache = True, name = [ "iptables-persistent" ] }
    }
  , Item::{
      name = Some "Set timezone to Europe/Stockholm",
      timezone = Some { name = "Europe/Stockholm" },
      notify = Some "restart cron"
    }
  , Item::{
      name = Some "Generate locale",
      locale_gen = Some { name = "{{ item }}", state = "present" },
      loop = Some [ "en_US.UTF-8", "sv_SE.UTF-8" ]
    }
  , Item::{
      name = Some "Install public keys",
      authorized_key = Some {
        user = "root"
      , state = "present"
      , key = "{{ lxd_guest_root_keys }}"
      , exclusive = True
    },
      when = Some "lxd_guest_root_keys is truthy"
    }
  , Item::{
      name = Some "Add default gateway as host",
      lineinfile = Some {
        path = "/etc/hosts"
      , line = "{{ ansible_default_ipv4.gateway }} gateway.lxd"
      , regex = "gateway.lxd$"
      , state = "present"
    }
    }
  , Item::{ import_role = Some "name=icos.fail2ban" }
]
