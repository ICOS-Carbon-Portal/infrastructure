-- Auto-generated from ../../../../devops/roles/icos.timer2/tasks/remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Stop and disable timer",
      command = Some "systemctl disable --now {{ timer_name }}.timer",
      register = Some "r",
      changed_when = Some (Task.Poly_changed_when.Bool False),
      failed_when = Some (Task.Poly_failed_when.Texts [ "r.rc != 0", "not r.stderr.endswith('does not exist.')" ])
    }
  , Task::{
      name = Some "Remove home directory",
      when = Some [ "timer_home != \"/etc/systemd/systemd\"" ],
      file = Some (Task.Poly_file.Record {
          path = Some "{{ timer_home }}",
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
]
