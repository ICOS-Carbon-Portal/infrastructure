-- Auto-generated from ../../../../devops/roles/icos.pgrep/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create pgrep directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ pgrep_home }}/volumes",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "0700",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Install peer certificate",
      copy = Some {
        dest = "{{ pgrep_home }}/peer.crt",
        mode = None Text,
        content = None Text,
        src = Some "{{ pgrep_peer_cert }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Install runtime files",
      template = Some {
        src = "{{ item.src }}",
        dest = "{{ pgrep_home }}",
        mode = Some "{{ item.mode | default(omit) }}",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "docker-compose.yml",
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "pgpass",
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "status.sql",
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "queries.yml",
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "entrypoint.sh",
            dest = None Text,
            name = None Text,
            mode = Some "+x",
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "psql",
            dest = None Text,
            name = None Text,
            mode = Some "+x",
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = Some "psql-peer",
            dest = None Text,
            name = None Text,
            mode = Some "+x",
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
      ])
    }
  , Task::{
      name = Some "Start containers",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ pgrep_home }}",
        state = None Text,
        pull = None Text,
        services = None ((List Text)),
        build = None Text
    }
    }
  , Task::{
      name = Some "Check that psql wrappers works",
      shell = Some ''
      {{ pgrep_home }}/{{ item }} -c 'select version()'

    '',
      changed_when = Some (Task.Poly_changed_when.Bool False),
      register = Some "_r",
      failed_when = Some (Task.Poly_failed_when.Texts [ "not 'PostgreSQL' in _r.stdout" ]),
      loop = Some (Task.Poly_loop.Texts [ "psql", "psql-peer" ])
    }
]
