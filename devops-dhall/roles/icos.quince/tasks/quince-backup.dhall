-- Auto-generated from ../../../../devops/roles/icos.quince/tasks/quince-backup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "bbclient",
      import_role = Some (Task.Poly_import_role.Record { name = "icos.bbclient2", tasks_from = None Text })
    }
  , Task::{
      name = Some "Copy quince-backup.sh",
      template = Some {
        src = "quince-backup.sh",
        dest = "{{ quince_home }}/backup.sh",
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
      name = Some "Install cron job for backups",
      cron = Some {
        user = Some "{{ quince_user }}",
        job = Some "{{ quince_home }}/backup.sh",
        hour = Some "*/3",
        minute = Some "15",
        name = "quince borg backup",
        state = None Text,
        special_time = None Text
    },
      when = Some [ "quince_backup_enable" ]
    }
]
