-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , include_role : Optional ({ name : Text, tasks_from : Optional Text })
    , vars : Optional ({ dbin_user : Optional Text, dbin_repo : Optional Text, dbin_url : Optional Text, dbin_download_dest : Optional Text, dbin_unar : Optional Bool, vmagent_config_dest : Optional Text, vmagent_config_content : Optional Text })
    , file : Optional ({ path : Text, state : Text })
    , blockinfile : Optional ({ marker : Text, create : Bool, insertafter : Text, path : Text, block : Text })
    , notify : Optional Text
    , import_tasks : Optional Text
    , template : Optional ({ dest : Text, src : Text })
    , register : Optional Text
    , systemd : Optional ({ `daemon-reload` : Text, name : Text, enabled : Bool, state : Text })
  }
    , default =
        { name = None Text
    , include_role = None ({ name : Text, tasks_from : Optional Text })
    , vars = None ({ dbin_user : Optional Text, dbin_repo : Optional Text, dbin_url : Optional Text, dbin_download_dest : Optional Text, dbin_unar : Optional Bool, vmagent_config_dest : Optional Text, vmagent_config_content : Optional Text })
    , file = None ({ path : Text, state : Text })
    , blockinfile = None ({ marker : Text, create : Bool, insertafter : Text, path : Text, block : Text })
    , notify = None Text
    , import_tasks = None Text
    , template = None ({ dest : Text, src : Text })
    , register = None Text
    , systemd = None ({ `daemon-reload` : Text, name : Text, enabled : Bool, state : Text })
  }
    }

in  [
    Item::{
      name = Some "Download script_exporter",
      include_role = Some { name = "icos.github_download_bin", tasks_from = None Text },
      vars = Some {
        dbin_user = Some "ricoberger"
      , dbin_repo = Some "script_exporter"
      , dbin_url = Some "{{ dbin__down }}/v{{ dbin__vers }}/script_exporter-linux-{{ sexp_arch }}"
      , dbin_download_dest = Some "{{ dbin_download_base }}/script-exporter-{{ dbin__vers }}"
      , dbin_unar = Some False
      , vmagent_config_dest = None Text
      , vmagent_config_content = None Text
    }
    }
  , Item::{
      name = Some "Create script_exporter home directory",
      file = Some { path = "{{ sexp_home }}", state = "directory" }
    }
  , Item::{
      name = Some "Add base config for script-exporter",
      blockinfile = Some {
        marker = "# {mark} base config"
      , create = True
      , insertafter = "BOF"
      , path = "{{ sexp_config_file }}"
      , block = "{{ lookup('template', 'config.yaml') }}"
    },
      notify = Some "reload script-exporter"
    }
  , Item::{ import_tasks = Some "scripts.yml" }
  , Item::{
      name = Some "Copy script-exporter systemd files",
      template = Some { dest = "/etc/systemd/system/", src = "script-exporter.service" },
      register = Some "_sysd"
    }
  , Item::{
      name = Some "Start/restart script-exporter.service",
      systemd = Some {
        `daemon-reload` = "{{ 'yes' if _sysd.changed else 'no' }}"
      , name = "script-exporter.service"
      , enabled = True
      , state = "started"
    }
    }
  , Item::{
      name = Some "Add ourselves to the local vmagent installation",
      include_role = Some { name = "icos.vmagent", tasks_from = Some "add_config" },
      vars = Some {
        dbin_user = None Text
      , dbin_repo = None Text
      , dbin_url = None Text
      , dbin_download_dest = None Text
      , dbin_unar = None Bool
      , vmagent_config_dest = Some "script-exporter-scripts.yaml"
      , vmagent_config_content = Some ''
        # These are the scripts exported by script-exporter.
        - job_name: script-exporter
          http_sd_configs:
            - url: http://localhost:9469/discovery
          relabel_configs:
            - target_label: instance
              replacement: {{ inventory_hostname_short }}

      ''
    }
    }
]
