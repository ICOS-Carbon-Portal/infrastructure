-- Auto-generated from ../../../../devops/roles/icos.postgis/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "docker.yml", tags = Some [ "postgis_setup" ] }
  , Task::{
      name = Some "Install postgis restore script",
      tags = Some [ "postgis_restore_script" ],
      template = Some {
        src = "restore_postgis_db.py",
        dest = "/usr/local/bin/restore_postgis_db.py",
        mode = Some "+x",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      import_tasks = Some "backup.yml",
      tags = Some [ "postgis_backup" ],
      when = Some [ "postgis_backup_enable" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "postgis_just" ] }
]
