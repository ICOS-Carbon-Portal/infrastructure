-- Auto-generated from ../../../../devops/roles/icos.restic_server/tasks/auth.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add restic users",
      htpasswd = Some {
        path = "{{ restic_server_htpasswd }}",
        name = "{{ item.name }}",
        password = "{{ item.password }}",
        crypt_scheme = Some "bcrypt",
        state = Some "{{ item.state | default(omit) }}"
    },
      loop = Some (Task.Poly_loop.Str "{{ restic_server_users }}")
    }
]
