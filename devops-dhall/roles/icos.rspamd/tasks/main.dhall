-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml", tags = Some [ "rspamd_install" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "rspamd_just" ] }
  , Task::{ import_tasks = Some "redis.yml", tags = Some [ "rspamd_redis" ] }
  , Task::{ import_tasks = Some "unbound.yml", tags = Some [ "rspamd_unbound" ] }
  , Task::{ import_tasks = Some "pyzor.yml", tags = Some [ "rspamd_pyzor" ] }
  , Task::{ import_tasks = Some "config.yml", tags = Some [ "rspamd_config" ] }
]
