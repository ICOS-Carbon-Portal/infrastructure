-- Auto-generated from ../../../../devops/roles/icos.postgresql/tasks/config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Change postgres user password",
      become = Some (Task.Poly_become.Bool True),
      become_user = Some "postgres",
      postgresql_user = Some {
        db = None Text,
        name = "postgres",
        password = "{{ postgresql_postgres_password }}",
        login_user = None Text,
        login_password = None Text,
        login_host = None Text,
        login_port = None Text,
        login_unix_socket = Some "/var/run/postgresql"
    },
      when = Some [ "postgresql_postgres_password" ]
    }
  , Task::{
      name = Some "Change with addresses postgresql listens to",
      copy = Some {
        dest = "{{ postgresql_confd }}/listen.conf",
        mode = None Text,
        content = Some ''
        listen_addresses = {{ postgresql_listen_addresses }}

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart postgresql" ],
      when = Some [ "postgresql_listen_addresses" ]
    }
  , Task::{
      name = Some "Install public keys for postgres user",
      tags = Some [ "keys" ],
      authorized_key = Some {
        user = "postgres",
        key = "{{ postgresql_ssh_keys }}",
        state = Some "present",
        exclusive = None Bool,
        key_options = None Text
    },
      when = Some [ "postgresql_ssh_keys" ]
    }
]
