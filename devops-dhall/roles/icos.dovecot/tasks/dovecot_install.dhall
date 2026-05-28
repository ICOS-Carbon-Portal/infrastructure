-- Auto-generated from dovecot_install.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text, state : Text })
    , service : Optional ({ name : Text, state : Text, enabled : Bool })
  }
    , default =
        { apt = None ({ name : List Text, state : Text })
    , service = None ({ name : Text, state : Text, enabled : Bool })
  }
    }

in  [
    Task::{
      name = "Install dovecot",
      apt = Some { name = [ "dovecot-imapd", "dovecot-lmtpd" ], state = "present" }
    }
  , Task::{
      name = "Enable dovecot",
      service = Some { name = "dovecot", state = "started", enabled = True }
    }
]
