-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "fail2ban reload",
      command = Some "fail2ban-client reload",
      register = Some "_r",
      failed_when = Some "_r.rc != 0 or \"OK\" not in _r.stdout",
      changed_when = Some "False"
    }
]
