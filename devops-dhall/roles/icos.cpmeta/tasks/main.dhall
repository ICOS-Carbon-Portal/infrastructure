-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : Text
    , when : Optional Text
    , vars : Optional ({ _restart_needed : Bool })
  }
    , default =
        { when = None Text
    , vars = None ({ _restart_needed : Bool })
  }
    }

in  [
    Item::{ import_tasks = "setup.yml", tags = "cpmeta_setup" }
  , Item::{
      import_tasks = "deploy.yml",
      tags = "cpmeta_deploy",
      when = Some "cpmeta_jar_file is defined"
    }
  , Item::{
      import_tasks = "restart.yml",
      tags = "cpmeta_restart",
      vars = Some { _restart_needed = True }
    }
  , Item::{
      import_tasks = "backup.yml",
      tags = "cpmeta_backup",
      when = Some "cpmeta_backup_enable | default(False)"
    }
]
