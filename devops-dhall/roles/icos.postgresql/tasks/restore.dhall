-- Auto-generated from ../../../../devops/roles/icos.postgresql/tasks/restore.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Extract \"{{ postgresql_container_name }}\" backup",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Record {
          cmd = "/usr/local/bin/restore_{{ postgresql_container_name }}_db.py --host={{ postgresql_backup_host }} --location={{ postgresql_backup_location }}"
      })
    }
]
