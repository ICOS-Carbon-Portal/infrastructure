-- Auto-generated from ../../../../devops/roles/icos.vmagent/handlers/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "reload vmagent",
      shell = Some "{{ vmagent_bin }}/vmagent-prod -dryRun -promscrape.config={{ vmagent_home }}/prometheus.yml && systemctl reload vmagent",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "restart vmagent",
      systemd = Some {
        name = Some "vmagent",
        state = Some "restarted",
        daemon_reload = Some True,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
