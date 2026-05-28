-- Auto-generated from grafana_datasource.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ grafana_datasource_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool, creates : Text })
    , diff : Optional Bool
    , debug : Optional ({ msg : Text })
  }
    , default =
        { when = None Text
    , run_once = None Bool
    , check_mode = None Bool
    , delegate_to = None Text
    , delegate_facts = None Bool
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ grafana_datasource_version : Text, cacheable : Bool }) }))
    , name = None Text
    , file = None ({ path : Text, state : Text })
    , unarchive = None ({ src : Text, dest : Text, remote_src : Bool, creates : Text })
    , diff = None Bool
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "grafana_datasource_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of grafana_datasource",
          github_release = Some {
            user = "VictoriaMetrics"
          , repo = "grafana-datasource"
          , action = "latest_release"
        },
          register = Some "gh",
          set_fact = None ({ grafana_datasource_version : Text, cacheable : Bool })
        }
      , {
          name = "Set grafana_datasource_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { grafana_datasource_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Create grafana plugin directory",
      file = Some { path = "{{ vm_graf_plugins }}", state = "directory" }
    }
  , Item::{
      name = Some "Install victoriametrics grafana-datasource",
      unarchive = Some {
        src = "https://github.com/VictoriaMetrics/victoriametrics-datasource/releases/download/v{{ hostvars.localhost.grafana_datasource_version }}/victoriametrics-metrics-datasource-v{{ hostvars.localhost.grafana_datasource_version }}.zip"
      , dest = "{{ vm_graf_plugins }}"
      , remote_src = True
      , creates = "{{omit if vm_upgrade else vm_graf_plugins + '/victoriametrics-datasource'}}"
    },
      diff = Some False
    }
  , Item::{
      name = Some "Which version of grafana-datasource was installed",
      debug = Some { msg = "Installed {{ hostvars.localhost.grafana_datasource_version }}" }
    }
]
