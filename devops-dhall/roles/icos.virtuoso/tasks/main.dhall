-- Auto-generated from ../../../../devops/roles/icos.virtuoso/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create volume directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ item }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      loop = Some (Task.Poly_loop.Texts [ "{{ virtuoso_home }}/volumes/virtuoso.db" ])
    }
  , Task::{
      name = Some "Copy virtuoso.ini",
      template = Some {
        src = "virtuoso.ini",
        dest = "{{ virtuoso_home }}/volumes/virtuoso.db/virtuoso.ini",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_virtuoso_ini"
    }
  , Task::{
      name = Some "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml",
        dest = "{{ virtuoso_home }}",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_virtuoso_compose"
    }
  , Task::{
      name = Some "Start Virtuoso",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ virtuoso_home }}",
        state = Some "present",
        pull = Some "always",
        services = None ((List Text)),
        build = None Text
    }
    }
  , Task::{
      name = Some "Restart Virtuoso if config changed",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ virtuoso_home }}",
        state = Some "restarted",
        pull = None Text,
        services = None ((List Text)),
        build = None Text
    },
      when = Some [ "_virtuoso_ini.changed or _virtuoso_compose.changed" ]
    }
]
