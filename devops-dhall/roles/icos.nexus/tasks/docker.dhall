-- Auto-generated from docker.yml

let Entry =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , template : Optional ({ src : Text, dest : Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text })
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , template = None ({ src : Text, dest : Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text })
  }
    }

in  [
    Entry::{
      name = "Create nexus home directory",
      file = Some { path = "{{ nexus_home }}", state = "directory" }
    }
  , Entry::{
      name = "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml", dest = "{{ nexus_home }}" }
    }
  , Entry::{
      name = "Start containers",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ nexus_home }}" }
    }
]
