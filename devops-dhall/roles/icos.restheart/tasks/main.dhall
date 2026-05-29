-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_tasks = Some "setup.yml",
      become = Some "True",
      become_user = Some "root",
      tags = Some [ "restheart_setup" ]
    }
  , Task::{
      import_tasks = Some "backup.yml",
      tags = Some [ "restheart_backup" ],
      when = Some [ "restheart_backup_enable | default(False)" ]
    }
]
