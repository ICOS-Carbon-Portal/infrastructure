-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Text
    , name : Optional Text
    , template : Optional ({ src : Text, dest : Text, mode : Text })
    , when : Optional Text
  }
    , default =
        { import_tasks = None Text
    , name = None Text
    , template = None ({ src : Text, dest : Text, mode : Text })
    , when = None Text
  }
    }

in  [
    Item::{ import_tasks = Some "docker.yml", tags = "postgis_setup" }
  , Item::{
      tags = "postgis_restore_script",
      name = Some "Install postgis restore script",
      template = Some {
        src = "restore_postgis_db.py"
      , dest = "/usr/local/bin/restore_postgis_db.py"
      , mode = "+x"
    }
    }
  , Item::{
      import_tasks = Some "backup.yml",
      tags = "postgis_backup",
      when = Some "postgis_backup_enable"
    }
  , Item::{ import_tasks = Some "just.yml", tags = "postgis_just" }
]
