-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , shell : Optional Text
    , changed_when : Optional Bool
    , systemd : Optional ({ name : Text, state : Text, daemon_reload : Bool })
  }
    , default =
        { shell = None Text
    , changed_when = None Bool
    , systemd = None ({ name : Text, state : Text, daemon_reload : Bool })
  }
    }

in  [
    Task::{
      name = "reload vmagent",
      shell = Some "{{ vmagent_bin }}/vmagent-prod -dryRun -promscrape.config={{ vmagent_home }}/prometheus.yml && systemctl reload vmagent",
      changed_when = Some False
    }
  , Task::{
      name = "restart vmagent",
      systemd = Some { name = "vmagent", state = "restarted", daemon_reload = True }
    }
]
