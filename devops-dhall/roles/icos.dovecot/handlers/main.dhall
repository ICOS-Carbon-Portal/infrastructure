-- Auto-generated from ../../../../devops/roles/icos.dovecot/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ name = Some "Reload postfix", command = Some "postfix reload" }
  , Task::{
      name = Some "Restart rsyslog",
      command = Some ''
      rsyslogd -N 1 && systemctl restart rsyslog

    '',
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
