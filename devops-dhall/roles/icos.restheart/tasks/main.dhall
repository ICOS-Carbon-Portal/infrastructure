-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , become : Optional Bool
    , become_user : Optional Text
    , tags : Text
    , when : Optional Text
  }
    , default =
        { become = None Bool
    , become_user = None Text
    , when = None Text
  }
    }

in  [
    Item::{
      import_tasks = "setup.yml",
      become = Some True,
      become_user = Some "root",
      tags = "restheart_setup"
    }
  , Item::{
      import_tasks = "backup.yml",
      tags = "restheart_backup",
      when = Some "restheart_backup_enable | default(False)"
    }
]
