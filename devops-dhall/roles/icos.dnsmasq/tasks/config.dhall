-- Auto-generated from ../../../../devops/roles/icos.dnsmasq/tasks/config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_tasks = Some "config_present.yml",
      when = Some [ "dnsmasq_config_state == \"present\"" ]
    }
  , Task::{
      import_tasks = Some "config_absent.yml",
      when = Some [ "dnsmasq_config_state == \"absent\"" ]
    }
]
