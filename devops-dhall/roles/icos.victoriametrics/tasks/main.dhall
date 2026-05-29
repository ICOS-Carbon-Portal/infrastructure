-- Auto-generated from ../../../../devops/roles/icos.victoriametrics/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create victoriametrics directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ vm_home }}/{{ item }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      loop = Some (Task.Poly_loop.Texts [ "victoriametrics/prometheus", "grafana/provisioning" ])
    }
  , Task::{
      name = Some "Change owner of grafana directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ vm_home }}/grafana",
          state = None Text,
          owner = Some "472",
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = Some True,
          src = None Text
      }),
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Copy files",
      template = Some {
        src = "{{ item.src }}",
        dest = "{{ vm_home }}/{{ item.dest | default('') }}",
        mode = None Text,
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
            src = Some "grafana.ini",
            dest = Some "grafana",
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
      ])
    }
  , Task::{
      name = Some "Create victoriametrics scrape config",
      copy = Some {
        dest = "{{ vm_home }}/victoriametrics/prometheus/prometheus.yml",
        mode = None Text,
        content = Some "{{ vm_scrape_conf }}",
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Build and start",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ vm_home }}",
        state = None Text,
        pull = Some "{{ 'always' if vm_upgrade else omit }}",
        services = None ((List Text)),
        build = None Text
    }
    }
  , Task::{ import_tasks = Some "grafana_datasource.yml", tags = Some [ "grafana_datasource" ] }
  , Task::{
      name = Some "Check that services responds on local ports",
      uri = Some {
        url = "http://localhost:{{ item.port }}",
        return_content = None Bool,
        method = None Text,
        user = None Text,
        password = None Text
    },
      retries = Some 10,
      loop_control = Some { loop_var = None Text, label = Some "{{ item.name }}" },
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
            src = None Text,
            dest = None Text,
            name = Some "victoriametrics",
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = Some "{{ vm_vm_port }}",
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
            src = None Text,
            dest = None Text,
            name = Some "grafana",
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = Some "{{ vm_graf_port }}",
            path = None Text
        }
      ])
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "victoriametrics_just" ] }
]
