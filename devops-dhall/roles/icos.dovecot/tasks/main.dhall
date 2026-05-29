-- Auto-generated from ../../../../devops/roles/icos.dovecot/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "dovecot_install.yml" }
  , Task::{ import_tasks = Some "dovecot_listen.yml" }
  , Task::{ import_tasks = Some "dovecot_logging.yml", tags = Some [ "dovecot_logging" ] }
  , Task::{ import_tasks = Some "dovecot_auth.yml" }
  , Task::{ import_tasks = Some "dovecot_ssl.yml", tags = Some [ "dovecot_ssl" ] }
  , Task::{ import_tasks = Some "dovecot_postfix.yml" }
  , Task::{ import_tasks = Some "dovecot_fail2ban.yml", tags = Some [ "dovecot_fail2ban" ] }
  , Task::{
      name = Some "Reload dovecot",
      shell = Some ''
      doveconf 1>/dev/null && doveadm reload

    '',
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
