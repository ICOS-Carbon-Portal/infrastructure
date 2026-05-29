-- Auto-generated from ../../../../devops/roles/icos.python_util/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copying python utility",
      copy = Some {
        dest = "{{ python_util_install_prefix }}",
        mode = None Text,
        content = None Text,
        src = Some "{{ python_util_src }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_util"
    }
  , Task::{
      name = Some "Installing python utility",
      `community.general.pipx` = Some {
        name = "{{ python_util_install_dir }}",
        executable = "pipx-global",
        python = Some "{{ python_util_python_executable }}",
        editable = Some True,
        force = None Text
    },
      register = Some "_pipx",
      changed_when = Some (Task.Poly_changed_when.Texts [
          "_pipx.changed"
        , "_pipx.stdout"
        , "_pipx.stdout.find('already seems to be installed') == -1"
      ])
    }
]
