-- Auto-generated from dovecot_auth.yml

let Entry =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, create_home : Bool, shell : Text })
    , register : Optional Text
    , template : Optional ({ src : Text, dest : Text })
    , lineinfile : Optional ({ path : Text, line : Text, state : Text })
  }
    , default =
        { user = None ({ name : Text, home : Text, create_home : Bool, shell : Text })
    , register = None Text
    , template = None ({ src : Text, dest : Text })
    , lineinfile = None ({ path : Text, line : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "Create dovecot vmail user",
      user = Some {
        name = "{{ dovecot_vmail_name }}"
      , home = "{{ dovecot_vmail_home }}"
      , create_home = True
      , shell = "/usr/sbin/nologin"
    },
      register = Some "dovecot_vmail_user"
    }
  , Entry::{
      name = "Copy {{ dovecot_auth_file }}",
      template = Some { src = "{{ dovecot_auth_file }}", dest = "/etc/dovecot/conf.d" }
    }
  , Entry::{
      name = "Add passwd-file authentication to dovecot",
      lineinfile = Some {
        path = "/etc/dovecot/conf.d/10-auth.conf"
      , line = "!include {{ dovecot_auth_file | basename }}"
      , state = "present"
    }
    }
]
