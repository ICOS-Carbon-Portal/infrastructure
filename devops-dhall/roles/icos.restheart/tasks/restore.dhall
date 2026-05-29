-- Auto-generated from restore.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Restore RestHeart backup",
      `ansible.builtin.script` = Some {
        cmd = "/usr/local/bin/restore_restheart_db.py --host={{ restheart_backup_host }} --location={{ restheart_backup_location }}"
      , executable = "/usr/bin/python3"
    }
    }
]
