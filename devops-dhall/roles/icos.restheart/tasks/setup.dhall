-- Auto-generated from setup.yml

let Entry =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , loop : Optional (List Text)
    , template : Optional ({ src : Text, dest : Text, mode : Optional Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, build : Bool })
    , tags : Optional Text
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , loop = None (List Text)
    , template = None ({ src : Text, dest : Text, mode : Optional Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text, build : Bool })
    , tags = None Text
  }
    }

in  [
    Entry::{
      name = "Create volume directories",
      file = Some { path = "{{ item }}", state = "directory" },
      loop = Some [ "{{ restheart_home }}/volumes/mongo.db" ]
    }
  , Entry::{
      name = "Copy restheart.yml",
      template = Some {
        src = "../templates/restheart.yml"
      , dest = "{{ restheart_home }}"
      , mode = None Text
    }
    }
  , Entry::{
      name = "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml", dest = "{{ restheart_home }}", mode = None Text }
    }
  , Entry::{
      name = "Build and start the images",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ restheart_home }}", build = True }
    }
  , Entry::{
      name = "Install restore script",
      template = Some { src = "restore_restheart_db.py", dest = "/usr/local/bin", mode = Some "+x" },
      tags = Some "restheart_restore_script"
    }
]
