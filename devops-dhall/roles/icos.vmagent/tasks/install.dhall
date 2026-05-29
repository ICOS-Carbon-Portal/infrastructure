-- Auto-generated from ../../../../devops/roles/icos.vmagent/tasks/install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create vmagent directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ item.path }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "{{ item.mode | default(omit) }}",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
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
            name = None Text,
            mode = Some "0700",
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = Some "{{ vmagent_home }}"
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
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = Some "{{ vmagent_bin }}"
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
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = Some "{{ vmagent_fsd }}"
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
            name = None Text,
            mode = None Text,
            key = None Text,
            val = None Text,
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = Some "{{ vmagent_configs }}"
        }
      ])
    }
  , Task::{
      name = Some "Check whether vmagent is installed",
      stat = Some { path = "{{ vmagent_bin }}/vmagent-prod" },
      register = Some "_vmagent"
    }
  , Task::{
      name = Some "Install/upgrade install vmagent",
      import_tasks = Some "really_install.yml",
      when = Some [ "not _vmagent.stat.exists or (vmagent_upgrade | default(False) | bool)" ]
    }
]
