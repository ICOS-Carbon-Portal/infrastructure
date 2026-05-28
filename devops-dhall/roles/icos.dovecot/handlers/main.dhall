-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , command : Text
    , changed_when : Optional Bool
  }
    , default =
        { changed_when = None Bool
  }
    }

in  [
    Entry::{ name = "Reload postfix", command = "postfix reload" }
  , Entry::{
      name = "Restart rsyslog",
      command = ''
      rsyslogd -N 1 && systemctl restart rsyslog

    '',
      changed_when = Some False
    }
]
