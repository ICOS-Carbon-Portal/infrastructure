-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , loop : Optional (List Text)
    , template : Optional ({ src : Text, dest : Text })
    , register : Optional Text
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Optional Text })
    , when : Optional Text
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , loop = None (List Text)
    , template = None ({ src : Text, dest : Text })
    , register = None Text
    , `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Optional Text })
    , when = None Text
  }
    }

in  [
    Entry::{
      name = "Create volume directories",
      file = Some { path = "{{ item }}", state = "directory" },
      loop = Some [ "{{ virtuoso_home }}/volumes/virtuoso.db" ]
    }
  , Entry::{
      name = "Copy virtuoso.ini",
      template = Some {
        src = "virtuoso.ini"
      , dest = "{{ virtuoso_home }}/volumes/virtuoso.db/virtuoso.ini"
    },
      register = Some "_virtuoso_ini"
    }
  , Entry::{
      name = "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml", dest = "{{ virtuoso_home }}" },
      register = Some "_virtuoso_compose"
    }
  , Entry::{
      name = "Start Virtuoso",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ virtuoso_home }}", state = "present", pull = Some "always" }
    }
  , Entry::{
      name = "Restart Virtuoso if config changed",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ virtuoso_home }}", state = "restarted", pull = None Text },
      when = Some "_virtuoso_ini.changed or _virtuoso_compose.changed"
    }
]
