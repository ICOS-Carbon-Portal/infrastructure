-- Auto-generated from ../../../../devops/roles/icos.postgresql/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml", tags = Some [ "postgresql_install" ] }
  , Task::{ import_tasks = Some "config.yml", tags = Some [ "postgresql_config" ] }
  , Task::{
      import_tasks = Some "pg_stat.yml",
      tags = Some [ "postgresql_pg_stat" ],
      when = Some [ "postgresql_pg_stat_enable" ]
    }
  , Task::{ import_tasks = Some "util.yml", tags = Some [ "postgresql_util" ] }
]
