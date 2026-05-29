-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create  directory",
      file = Some {
        path = Some "{{ fairdolab_home }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Clone fairdolab",
      git = Some {
        repo = "https://github.com/kit-data-manager/FAIR-DO-Lab"
      , version = None Text
      , dest = "{{ fairdolab_home }}"
      , force = None Bool
      , update = Some "False"
      , key_file = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Create docker-compose.yml",
      template = Some {
        src = "docker-compose.yml"
      , dest = "{{ fairdolab_home }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    }
    }
  , Task::{
      name = Some "Build and start",
      docker_compose = Some {
        project_src = "{{ fairdolab_home }}"
      , build = Some True
      , restarted = None Text
      , state = None Text
    }
    }
]
