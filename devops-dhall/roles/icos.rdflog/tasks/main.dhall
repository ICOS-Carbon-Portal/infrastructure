-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ path : Text, state : Text, mode : Optional Natural })
    , copy : Optional ({ dest : Text, src : Text })
    , loop : Optional (List Text)
    , template : Optional ({ dest : Text, src : Text, mode : Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text })
    , shell : Optional Text
    , register : Optional Text
    , changed_when : Optional Bool
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
    , import_tasks : Optional Text
    , tags : Optional Text
    , when : Optional Text
  }
    , default =
        { name = None Text
    , file = None ({ path : Text, state : Text, mode : Optional Natural })
    , copy = None ({ dest : Text, src : Text })
    , loop = None (List Text)
    , template = None ({ dest : Text, src : Text, mode : Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text })
    , shell = None Text
    , register = None Text
    , changed_when = None Bool
    , retries = None Natural
    , delay = None Natural
    , until = None Text
    , import_tasks = None Text
    , tags = None Text
    , when = None Text
  }
    }

in  [
    Item::{
      name = Some "Create directories",
      file = Some { path = "{{ rdflog_home }}", state = "directory", mode = Some 448 }
    }
  , Item::{
      name = Some "Create rdflog initdb",
      file = Some { path = "{{ rdflog_home }}/initdb", state = "directory", mode = None Natural }
    }
  , Item::{
      name = Some "Install postgres ssl key/certificate",
      copy = Some { dest = "{{ rdflog_home }}/initdb", src = "{{ item }}" },
      loop = Some [ "server.crt", "server.key" ]
    }
  , Item::{
      name = Some "Install templates",
      loop = Some [
        { src = "status.sql", dest = None Text, mode = None Text }
      , { src = "ctl.sql", dest = None Text, mode = None Text }
      , { src = "docker-compose.yml", dest = None Text, mode = None Text }
      , { src = "init.sql", dest = Some "{{ rdflog_home }}/initdb", mode = None Text }
      , { src = "init.sh", dest = Some "{{ rdflog_home }}/initdb", mode = None Text }
      , { src = "psql.sh", dest = None Text, mode = Some "+x" }
    ],
      template = Some {
        dest = "{{ item.dest | default(rdflog_home) }}"
      , src = "{{ item.src }}"
      , mode = "{{ item.mode | default(omit) }}"
    }
    }
  , Item::{
      name = Some "Start containers",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ rdflog_home }}" }
    }
  , Item::{
      name = Some "Test database connection (by loading ctl.sql)",
      shell = Some "{{ rdflog_home }}/psql.sh {{ rdflog_db_name }} < {{ rdflog_home }}/ctl.sql",
      register = Some "r",
      changed_when = Some False,
      retries = Some 10,
      delay = Some 5,
      until = Some "r.rc == 0"
    }
  , Item::{
      import_tasks = Some "restore.yml",
      tags = Some "rdflog_restore",
      when = Some "rdflog_restore_file is defined"
    }
]
