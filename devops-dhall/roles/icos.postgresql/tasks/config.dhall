-- Auto-generated from config.yml

let Task =
    { Type =
        { name : Text
    , become : Optional Bool
    , become_user : Optional Text
    , postgresql_user : Optional ({ name : Text, password : Text, login_unix_socket : Text })
    , when : List Text
    , copy : Optional ({ dest : Text, content : Text })
    , notify : Optional Text
    , tags : Optional Text
    , authorized_key : Optional ({ user : Text, state : Text, key : Text })
  }
    , default =
        { become = None Bool
    , become_user = None Text
    , postgresql_user = None ({ name : Text, password : Text, login_unix_socket : Text })
    , copy = None ({ dest : Text, content : Text })
    , notify = None Text
    , tags = None Text
    , authorized_key = None ({ user : Text, state : Text, key : Text })
  }
    }

in  [
    Task::{
      name = "Change postgres user password",
      become = Some True,
      become_user = Some "postgres",
      postgresql_user = Some {
        name = "postgres"
      , password = "{{ postgresql_postgres_password }}"
      , login_unix_socket = "/var/run/postgresql"
    },
      when = [ "postgresql_postgres_password" ]
    }
  , Task::{
      name = "Change with addresses postgresql listens to",
      when = [ "postgresql_listen_addresses" ],
      copy = Some {
        dest = "{{ postgresql_confd }}/listen.conf"
      , content = ''
        listen_addresses = {{ postgresql_listen_addresses }}

      ''
    },
      notify = Some "restart postgresql"
    }
  , Task::{
      name = "Install public keys for postgres user",
      when = [ "postgresql_ssh_keys" ],
      tags = Some "keys",
      authorized_key = Some { user = "postgres", state = "present", key = "{{ postgresql_ssh_keys }}" }
    }
]
