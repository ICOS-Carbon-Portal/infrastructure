-- Auto-generated from ../../../../devops/roles/icos.fail2ban/tasks/config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create fail2ban config files",
      copy = Some {
        dest = "{{ item.dest }}",
        mode = None Text,
        content = Some "{{ item.content }}",
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ fail2ban_config_files }}"),
      loop_control = Some { loop_var = None Text, label = Some "{{ item.dest }}" },
      notify = Some [ "fail2ban reload" ]
    }
]
