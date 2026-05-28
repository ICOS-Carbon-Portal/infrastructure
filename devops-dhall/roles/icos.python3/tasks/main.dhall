-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ update_cache : Optional Bool, cache_valid_time : Optional Natural, name : List Text })
    , when : Optional Text
    , apt_repository : Optional ({ repo : Text })
    , loop : Optional Text
    , loop_control : Optional ({ loop_var : Text })
    , vars : Optional ({ _builtin_version : Text })
  }
    , default =
        { apt = None ({ update_cache : Optional Bool, cache_valid_time : Optional Natural, name : List Text })
    , when = None Text
    , apt_repository = None ({ repo : Text })
    , loop = None Text
    , loop_control = None ({ loop_var : Text })
    , vars = None ({ _builtin_version : Text })
  }
    }

in  [
    Task::{
      name = "Install pip and venv",
      apt = Some {
        update_cache = Some True
      , cache_valid_time = Some 86400
      , name = [ "python3-pip", "python3-virtualenv", "python3-venv" ]
    }
    }
  , Task::{
      name = "Add ppa:deadsnakes repository",
      when = Some "ansible_distribution == \"Ubuntu\"",
      apt_repository = Some { repo = "ppa:deadsnakes/ppa" }
    }
  , Task::{
      name = "Install extra version of python",
      apt = Some {
        update_cache = None Bool
      , cache_valid_time = None Natural
      , name = [ "python{{ _version }}-venv" ]
    },
      when = Some "_builtin_version != _version",
      loop = Some "{{ python3_version_list }}",
      loop_control = Some { loop_var = "_version" },
      vars = Some {
        _builtin_version = "{{ ansible_python.version.major }}.{{ ansible_python.version.minor }}"
    }
    }
]
