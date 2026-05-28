-- Auto-generated from scripts.yml

let Task =
    { Type =
        { name : Text
    , git : Optional ({ repo : Text, version : Text, dest : Text })
    , diff : Optional Bool
    , pip : Optional ({ virtualenv : Text, name : List Text })
    , apt : Optional ({ name : List Text })
  }
    , default =
        { git = None ({ repo : Text, version : Text, dest : Text })
    , diff = None Bool
    , pip = None ({ virtualenv : Text, name : List Text })
    , apt = None ({ name : List Text })
  }
    }

in  [
    Task::{
      name = "Clone textfile-collector-scripts",
      git = Some {
        repo = "https://github.com/prometheus-community/node-exporter-textfile-collector-scripts"
      , version = "master"
      , dest = "{{ sexp_scripts_repo }}"
    },
      diff = Some False
    }
  , Task::{
      name = "Create virtual env for scripts",
      pip = Some {
        virtualenv = "{{ sexp_scripts_venv }}"
      , name = [
          "prometheus_client"
        , "{{ 'docker' if 'smartmon' in sexp_exporters else omit }}"
      ]
    }
    }
  , Task::{
      name = "Install utils needed for the collector-scripts",
      apt = Some {
        name = [
          "moreutils"
        , "{{ 'smartmontools' if 'smartmon' in sexp_exporters else omit }}"
      ]
    }
    }
]
