-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , template : Optional ({ src : Text, dest : Text, lstrip_blocks : Optional Bool })
    , register : Optional Text
    , copy : Optional ({ src : Text, dest : Text })
    , loop : Optional (List Text)
    , icos_docker_compose : Optional ({ chdir : Text, force_recreate : Text })
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , template = None ({ src : Text, dest : Text, lstrip_blocks : Optional Bool })
    , register = None Text
    , copy = None ({ src : Text, dest : Text })
    , loop = None (List Text)
    , icos_docker_compose = None ({ chdir : Text, force_recreate : Text })
  }
    }

in  [
    Task::{
      name = "Create fairdatapoint directory",
      file = Some { path = "{{ fdp_home }}/", state = "directory" }
    }
  , Task::{
      name = "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml", dest = "{{ fdp_home }}", lstrip_blocks = Some True },
      register = Some "_compose"
    }
  , Task::{
      name = "Copy Dockerfile",
      template = Some { src = "Dockerfile", dest = "{{ fdp_home }}", lstrip_blocks = None Bool },
      register = Some "_dockerfile"
    }
  , Task::{
      name = "Copy jarfile",
      register = Some "_jarfile",
      copy = Some { src = "{{ fdp_jar_file }}", dest = "{{ fdp_home }}/fdp.jar" }
    }
  , Task::{
      name = "Copy application.yml",
      template = Some { src = "application.yml", dest = "{{ fdp_home }}/", lstrip_blocks = Some True },
      register = Some "_config"
    }
  , Task::{
      name = "Copy files",
      copy = Some { dest = "{{ fdp_home }}", src = "{{ item }}" },
      loop = Some [ "eh-next_logo.png", "_variables.scss" ]
    }
  , Task::{
      name = "Start fairdatapoint",
      icos_docker_compose = Some {
        chdir = "{{ fdp_home }}"
      , force_recreate = "{{ _config.changed or _compose.changed or _jarfile.changed or _dockerfile.changed }}"
    }
    }
]
