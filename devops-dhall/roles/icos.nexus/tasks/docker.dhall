-- Auto-generated from docker.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create nexus home directory",
      file = Some {
        path = Some "{{ nexus_home }}"
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
      , dest = "{{ nexus_home }}"
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
      name = Some "Start containers",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ nexus_home }}"
      , state = None Text
      , pull = None Text
      , services = None (List Text)
      , build = None Text
    }
    }
]
