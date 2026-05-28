-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : List Text
    , name : Optional Text
  }
    , default =
        { name = None Text
  }
    }

in  [
    Item::{ import_tasks = "quince-system.yml", tags = [ "quince-system" ] }
  , Item::{
      import_tasks = "quince-tomcat.yml",
      tags = [ "quince-setup", "quince-tomcat" ],
      name = Some "Download specific version of tomcat"
    }
  , Item::{
      import_tasks = "quince-mysql.yml",
      tags = [ "quince-setup", "quince-mysql" ],
      name = Some "Setup mysql database"
    }
  , Item::{
      import_tasks = "quince-backup.yml",
      tags = [ "quince-backup", "quince-backup-script" ],
      name = Some "Install backup script"
    }
  , Item::{ import_tasks = "quince-logging.yml", tags = [ "quince-logging" ] }
]
