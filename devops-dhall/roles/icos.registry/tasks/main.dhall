-- Auto-generated from ../../../../devops/roles/icos.registry/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "auth.yml", tags = Some [ "registry_auth" ] }
  , Task::{
      name = Some "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml",
        dest = "{{ registry_home }}/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Create http secret",
      shell = Some "openssl rand -hex 20 | awk '{ print \"REGISTRY_HTTP_SECRET=\" $1 }' > .env",
      args = Some {
        chdir = Some "{{ registry_home }}",
        creates = Some ".env",
        executable = None Text,
        removes = None Text
    }
    }
  , Task::{
      name = Some "Start Build and start containers",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ registry_home }}",
        state = None Text,
        pull = None Text,
        services = None ((List Text)),
        build = None Text
    }
    }
]
