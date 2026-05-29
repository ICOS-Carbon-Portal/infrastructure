-- Auto-generated from ../../../../devops/roles/icos.vmagent/tasks/assert_installed.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check whether vmagent is installed",
      stat = Some { path = "{{ vmagent_configs }}" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Fail if vmagent isn't installed",
      fail = Some { msg = "vmagent isn't installed on this machine" },
      when = Some [ "not _r.stat.exists" ]
    }
]
