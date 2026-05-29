-- Auto-generated from dovecot_install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install dovecot",
      apt = Some {
        name = Some [ "dovecot-imapd", "dovecot-lmtpd" ]
      , state = Some "present"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Enable dovecot",
      service = Some { name = "dovecot", state = "started", enabled = Some True }
    }
]
