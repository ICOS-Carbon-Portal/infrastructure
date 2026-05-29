-- Auto-generated from ../../../../devops/roles/icos.rdflog/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ rdflog_home }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "448",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Create rdflog initdb",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ rdflog_home }}/initdb",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Install postgres ssl key/certificate",
      copy = Some {
        dest = "{{ rdflog_home }}/initdb",
        mode = None Text,
        content = None Text,
        src = Some "{{ item }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "server.crt", "server.key" ])
    }
  , Task::{
      name = Some "Install templates",
      template = Some {
        src = "{{ item.src }}",
        dest = "{{ item.dest | default(rdflog_home) }}",
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
            src = Some "ctl.sql",
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
            src = Some "init.sql",
            dest = Some "{{ rdflog_home }}/initdb",
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
            src = Some "init.sh",
            dest = Some "{{ rdflog_home }}/initdb",
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
            src = Some "psql.sh",
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
        project_src = "{{ rdflog_home }}",
        state = None Text,
        pull = None Text,
        services = None ((List Text)),
        build = None Text
    }
    }
  , Task::{
      name = Some "Test database connection (by loading ctl.sql)",
      shell = Some "{{ rdflog_home }}/psql.sh {{ rdflog_db_name }} < {{ rdflog_home }}/ctl.sql",
      register = Some "r",
      changed_when = Some (Task.Poly_changed_when.Bool False),
      retries = Some 10,
      delay = Some 5,
      until = Some "r.rc == 0"
    }
  , Task::{
      import_tasks = Some "restore.yml",
      tags = Some [ "rdflog_restore" ],
      when = Some [ "rdflog_restore_file is defined" ]
    }
]
