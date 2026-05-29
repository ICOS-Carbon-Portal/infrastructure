-- Auto-generated from ../../../../devops/roles/icos.dnsmasq/tasks/config_absent.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Fail if user is trying to remove main config file",
      fail = Some { msg = "We're not setup to remove the default config file." },
      when = Some [ "dnsmasq_config_name == \"config\"" ]
    }
  , Task::{
      name = Some "Remove dnsmasq config file",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "{{ dnsmasq_config_file }}",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      notify = Some [ "dnsmasq restart" ]
    }
]
