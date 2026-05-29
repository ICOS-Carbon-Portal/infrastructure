-- Auto-generated from ../../../../devops/roles/icos.fail2ban/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "fail2ban_setup" ] }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "fail2ban_just" ] }
  , Task::{ import_tasks = Some "config.yml", tags = Some [ "fail2ban_config" ] }
]
