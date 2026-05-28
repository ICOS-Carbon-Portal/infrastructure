-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text, mode : Text })
    , copy : Optional ({ src : Text, dest : Text })
    , template : Optional ({ src : Text, dest : Text, mode : Text })
    , loop : Optional (List Text)
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , failed_when : Optional (List Text)
  }
    , default =
        { file = None ({ path : Text, state : Text, mode : Text })
    , copy = None ({ src : Text, dest : Text })
    , template = None ({ src : Text, dest : Text, mode : Text })
    , loop = None (List Text)
    , `community.docker.docker_compose_v2` = None ({ project_src : Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None (List Text)
  }
    }

in  [
    Task::{
      name = "Create pgrep directories",
      file = Some { path = "{{ pgrep_home }}/volumes", state = "directory", mode = "0700" }
    }
  , Task::{
      name = "Install peer certificate",
      copy = Some { src = "{{ pgrep_peer_cert }}", dest = "{{ pgrep_home }}/peer.crt" }
    }
  , Task::{
      name = "Install runtime files",
      template = Some {
        src = "{{ item.src }}"
      , dest = "{{ pgrep_home }}"
      , mode = "{{ item.mode | default(omit) }}"
    },
      loop = Some [
        { src = "docker-compose.yml", mode = None Text }
      , { src = "pgpass", mode = None Text }
      , { src = "status.sql", mode = None Text }
      , { src = "queries.yml", mode = None Text }
      , { src = "entrypoint.sh", mode = Some "+x" }
      , { src = "psql", mode = Some "+x" }
      , { src = "psql-peer", mode = Some "+x" }
    ]
    }
  , Task::{
      name = "Start containers",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ pgrep_home }}" }
    }
  , Task::{
      name = "Check that psql wrappers works",
      loop = Some [ "psql", "psql-peer" ],
      shell = Some ''
      {{ pgrep_home }}/{{ item }} -c 'select version()'

    '',
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some [ "not 'PostgreSQL' in _r.stdout" ]
    }
]
