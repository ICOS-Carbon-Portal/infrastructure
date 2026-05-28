-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ src : Text, dest : Text })
    , register : Text
    , `community.general.pipx` : Optional ({ executable : Text, python : Text, editable : Bool, name : Text })
    , changed_when : Optional (List Text)
  }
    , default =
        { copy = None ({ src : Text, dest : Text })
    , `community.general.pipx` = None ({ executable : Text, python : Text, editable : Bool, name : Text })
    , changed_when = None (List Text)
  }
    }

in  [
    Task::{
      name = "Copying python utility",
      copy = Some { src = "{{ python_util_src }}", dest = "{{ python_util_install_prefix }}" },
      register = "_util"
    }
  , Task::{
      name = "Installing python utility",
      register = "_pipx",
      `community.general.pipx` = Some {
        executable = "pipx-global"
      , python = "{{ python_util_python_executable }}"
      , editable = True
      , name = "{{ python_util_install_dir }}"
    },
      changed_when = Some [
        "_pipx.changed"
      , "_pipx.stdout"
      , "_pipx.stdout.find('already seems to be installed') == -1"
    ]
    }
]
