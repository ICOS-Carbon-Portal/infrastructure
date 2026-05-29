-- Auto-generated from users.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create postgres db users",
      become = Some "True",
      postgresql_user = Some {
        db = Some "{{ db_name }}"
      , name = "{{ item.username }}"
      , password = "{{ item.password }}"
      , login_user = Some "{{ postgis_db_user }}"
      , login_password = Some "{{ postgis_db_pass }}"
      , login_host = Some "127.0.0.1"
      , login_port = Some "{{ postgis_db_port }}"
      , login_unix_socket = None Text
    },
      loop = Some [ "{{ postgis_db_users }}" ]
    }
]
