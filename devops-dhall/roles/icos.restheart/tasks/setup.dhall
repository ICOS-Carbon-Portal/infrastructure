-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create volume directories",
      file = Some {
        path = Some "{{ item }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      loop = Some [ "{{ restheart_home }}/volumes/mongo.db" ]
    }
  , Task::{
      name = Some "Copy restheart.yml",
      template = Some {
        src = "../templates/restheart.yml"
      , dest = "{{ restheart_home }}"
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
      name = Some "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml"
      , dest = "{{ restheart_home }}"
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
      name = Some "Build and start the images",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ restheart_home }}"
      , state = None Text
      , pull = None Text
      , services = None (List Text)
      , build = Some "True"
    }
    }
  , Task::{
      name = Some "Install restore script",
      tags = Some [ "restheart_restore_script" ],
      template = Some {
        src = "restore_restheart_db.py"
      , dest = "/usr/local/bin"
      , mode = Some "+x"
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    }
    }
]
