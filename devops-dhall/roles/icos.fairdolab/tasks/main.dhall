-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , git : Optional ({ repo : Text, dest : Text, update : Bool })
    , diff : Optional Bool
    , template : Optional ({ dest : Text, src : Text })
    , docker_compose : Optional ({ project_src : Text, build : Bool })
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , git = None ({ repo : Text, dest : Text, update : Bool })
    , diff = None Bool
    , template = None ({ dest : Text, src : Text })
    , docker_compose = None ({ project_src : Text, build : Bool })
  }
    }

in  [
    Entry::{
      name = "Create  directory",
      file = Some { path = "{{ fairdolab_home }}", state = "directory" }
    }
  , Entry::{
      name = "Clone fairdolab",
      git = Some {
        repo = "https://github.com/kit-data-manager/FAIR-DO-Lab"
      , dest = "{{ fairdolab_home }}"
      , update = False
    },
      diff = Some False
    }
  , Entry::{
      name = "Create docker-compose.yml",
      template = Some { dest = "{{ fairdolab_home }}", src = "docker-compose.yml" }
    }
  , Entry::{
      name = "Build and start",
      docker_compose = Some { project_src = "{{ fairdolab_home }}", build = True }
    }
]
