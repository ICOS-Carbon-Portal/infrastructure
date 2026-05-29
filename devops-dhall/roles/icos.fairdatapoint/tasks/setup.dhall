-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create fairdatapoint directory",
      file = Some {
        path = Some "{{ fdp_home }}/"
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
      name = Some "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml"
      , dest = "{{ fdp_home }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = Some True
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      register = Some "_compose"
    }
  , Task::{
      name = Some "Copy Dockerfile",
      template = Some {
        src = "Dockerfile"
      , dest = "{{ fdp_home }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      register = Some "_dockerfile"
    }
  , Task::{
      name = Some "Copy jarfile",
      copy = Some {
        src = Some "{{ fdp_jar_file }}"
      , dest = "{{ fdp_home }}/fdp.jar"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      register = Some "_jarfile"
    }
  , Task::{
      name = Some "Copy application.yml",
      template = Some {
        src = "application.yml"
      , dest = "{{ fdp_home }}/"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = Some True
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      register = Some "_config"
    }
  , Task::{
      name = Some "Copy files",
      copy = Some {
        src = Some "{{ item }}"
      , dest = "{{ fdp_home }}"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "eh-next_logo.png", "_variables.scss" ]
    }
  , Task::{
      name = Some "Start fairdatapoint",
      icos_docker_compose = Some {
        chdir = "{{ fdp_home }}"
      , force_recreate = "{{ _config.changed or _compose.changed or _jarfile.changed or _dockerfile.changed }}"
    }
    }
]
