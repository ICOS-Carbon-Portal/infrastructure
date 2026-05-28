-- Auto-generated from barebones.yml

let Entry =
    { Type =
        { name : Text
    , `community.general.docker_container` : Optional ({ name : Text, image : Text, state : Text, recreate : Bool, env : { POSTGRES_USER : Text, POSTGRES_PASSWORD : Text, POSTGRES_DB : Text }, published_ports : List Text, volumes : List Text, restart_policy : Text })
    , wait_for : Optional ({ host : Text, port : Text, delay : Natural, timeout : Natural })
  }
    , default =
        { `community.general.docker_container` = None ({ name : Text, image : Text, state : Text, recreate : Bool, env : { POSTGRES_USER : Text, POSTGRES_PASSWORD : Text, POSTGRES_DB : Text }, published_ports : List Text, volumes : List Text, restart_policy : Text })
    , wait_for = None ({ host : Text, port : Text, delay : Natural, timeout : Natural })
  }
    }

in  [
    Entry::{
      name = "(Re-)install rdflog postgres container",
      `community.general.docker_container` = Some {
        name = "rdflog"
      , image = "postgres:{{ rdflog_postgres_version }}"
      , state = "started"
      , recreate = False
      , env = {
          POSTGRES_USER = "{{ rdflog_db_user }}"
        , POSTGRES_PASSWORD = "{{ rdflog_db_pass }}"
        , POSTGRES_DB = "{{ rdflog_db_name }}"
      }
      , published_ports = [ "127.0.0.1:{{ rdflog_db_port }}:5432" ]
      , volumes = [ "/docker/rdflog/volumes/data:/var/lib/postgresql/data" ]
      , restart_policy = "always"
    }
    }
  , Entry::{
      name = "Wait for rdflog db to become available",
      wait_for = Some {
        host = "127.0.0.1"
      , port = "{{ rdflog_db_port }}"
      , delay = 5
      , timeout = 60
    }
    }
]
