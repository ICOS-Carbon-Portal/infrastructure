-- Auto-generated from auth.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add restic users",
      htpasswd = Some {
        path = "{{ restic_server_htpasswd }}"
      , name = "{{ item.name }}"
      , password = "{{ item.password }}"
      , crypt_scheme = Some "bcrypt"
      , state = Some "{{ item.state | default(omit) }}"
    },
      loop = Some [ "{{ restic_server_users }}" ]
    }
]
