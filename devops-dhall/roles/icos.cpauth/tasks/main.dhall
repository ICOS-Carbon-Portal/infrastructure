-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : Text
    , when : Optional Text
  }
    , default =
        { when = None Text
  }
    }

in  [
    Item::{ import_tasks = "setup.yml", tags = "cpauth_setup" }
  , Item::{
      import_tasks = "deploy.yml",
      tags = "cpauth_deploy",
      when = Some "cpauth_jar_file is defined"
    }
  , Item::{ import_tasks = "backup.yml", tags = "cpauth_backup" }
]
