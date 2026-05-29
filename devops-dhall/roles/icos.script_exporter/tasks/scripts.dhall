-- Auto-generated from scripts.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Clone textfile-collector-scripts",
      git = Some {
        repo = "https://github.com/prometheus-community/node-exporter-textfile-collector-scripts"
      , version = Some "master"
      , dest = "{{ sexp_scripts_repo }}"
      , force = None Bool
      , update = None Text
      , key_file = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Create virtual env for scripts",
      pip = Some {
        name = [
          "prometheus_client"
        , "{{ 'docker' if 'smartmon' in sexp_exporters else omit }}"
      ]
      , virtualenv = Some "{{ sexp_scripts_venv }}"
      , state = None Text
    }
    }
  , Task::{
      name = Some "Install utils needed for the collector-scripts",
      apt = Some {
        name = Some [
          "moreutils"
        , "{{ 'smartmontools' if 'smartmon' in sexp_exporters else omit }}"
      ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
]
