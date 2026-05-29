-- Auto-generated from ../../../../devops/roles/icos.jupyter/tasks/jusers.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove virtual env",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ jusers_venv }}",
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      when = Some [ "virtualenv_recreate | default(False) | bool" ]
    }
  , Task::{
      name = Some "Create virtual env",
      pip = Some (Task.Poly_pip.Record {
          name = [ "ruamel.yaml", "click", "pandas", "requests" ],
          virtualenv = Some "{{ jusers_venv }}",
          state = Some "present"
      })
    }
  , Task::{
      name = Some "Copy jusers.py",
      template = Some {
        src = "jusers.py",
        dest = "{{ jusers_home }}/jusers.py",
        mode = Some "+x",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = Some True,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Copy plugins",
      copy = Some {
        dest = "{{ jusers_home }}/",
        mode = None Text,
        content = None Text,
        src = Some "plugins",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Copy readme_template.html",
      copy = Some {
        dest = "/root/readme_template.html",
        mode = None Text,
        content = None Text,
        src = Some "readme_template.html",
        backup = Some True,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Create /usr/local/sbin/jusers symlink",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "/usr/local/sbin/jusers",
          recurse = None Bool,
          src = Some "{{ jusers_home }}/jusers.py"
      })
    }
  , Task::{
      name = Some "Check that jusers executes",
      shell = Some "/usr/local/sbin/jusers",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
