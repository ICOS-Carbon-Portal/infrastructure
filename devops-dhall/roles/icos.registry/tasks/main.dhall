-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional Text
    , name : Optional Text
    , template : Optional ({ src : Text, dest : Text })
    , shell : Optional Text
    , args : Optional ({ chdir : Text, creates : Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text })
  }
    , default =
        { import_tasks = None Text
    , tags = None Text
    , name = None Text
    , template = None ({ src : Text, dest : Text })
    , shell = None Text
    , args = None ({ chdir : Text, creates : Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text })
  }
    }

in  [
    Item::{ import_tasks = Some "auth.yml", tags = Some "registry_auth" }
  , Item::{
      name = Some "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml", dest = "{{ registry_home }}/" }
    }
  , Item::{
      name = Some "Create http secret",
      shell = Some "openssl rand -hex 20 | awk '{ print \"REGISTRY_HTTP_SECRET=\" $1 }' > .env",
      args = Some { chdir = "{{ registry_home }}", creates = ".env" }
    }
  , Item::{
      name = Some "Start Build and start containers",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ registry_home }}" }
    }
]
