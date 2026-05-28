-- Auto-generated from quince-backup.yml

let Task =
    { Type =
        { name : Text
    , import_role : Optional ({ name : Text })
    , template : Optional ({ src : Text, dest : Text, mode : Text })
    , cron : Optional ({ user : Text, name : Text, minute : Text, hour : Text, job : Text })
    , when : Optional Text
  }
    , default =
        { import_role = None ({ name : Text })
    , template = None ({ src : Text, dest : Text, mode : Text })
    , cron = None ({ user : Text, name : Text, minute : Text, hour : Text, job : Text })
    , when = None Text
  }
    }

in  [
    Task::{ name = "bbclient", import_role = Some { name = "icos.bbclient2" } }
  , Task::{
      name = "Copy quince-backup.sh",
      template = Some { src = "quince-backup.sh", dest = "{{ quince_home }}/backup.sh", mode = "+x" }
    }
  , Task::{
      name = "Install cron job for backups",
      cron = Some {
        user = "{{ quince_user }}"
      , name = "quince borg backup"
      , minute = "15"
      , hour = "*/3"
      , job = "{{ quince_home }}/backup.sh"
    },
      when = Some "quince_backup_enable"
    }
]
