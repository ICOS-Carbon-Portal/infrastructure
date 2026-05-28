-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional Text
    , name : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { import_tasks = None Text
    , tags = None Text
    , name = None Text
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Item::{ import_tasks = Some "dovecot_install.yml" }
  , Item::{ import_tasks = Some "dovecot_listen.yml" }
  , Item::{ import_tasks = Some "dovecot_logging.yml", tags = Some "dovecot_logging" }
  , Item::{ import_tasks = Some "dovecot_auth.yml" }
  , Item::{ import_tasks = Some "dovecot_ssl.yml", tags = Some "dovecot_ssl" }
  , Item::{ import_tasks = Some "dovecot_postfix.yml" }
  , Item::{ import_tasks = Some "dovecot_fail2ban.yml", tags = Some "dovecot_fail2ban" }
  , Item::{
      name = Some "Reload dovecot",
      shell = Some ''
      doveconf 1>/dev/null && doveadm reload

    '',
      changed_when = Some False
    }
]
