-- Auto-generated from ../../../../devops/roles/icos.nebula/tasks/resolve.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      when = Some [ "nebula_resolve_type == \"probe\"" ],
      include_tasks = Some (Task.Poly_include_tasks.Str "resolve-probe.yml")
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"dnsmasq\"" ],
      include_tasks = Some (Task.Poly_include_tasks.Str "resolve-dnsmasq.yml")
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"NetworkManager\"" ],
      include_tasks = Some (Task.Poly_include_tasks.Str "resolve-networkmanager.yml")
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"systemd-networkd\"" ],
      include_tasks = Some (Task.Poly_include_tasks.Str "resolve-networkd.yml")
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"unknown\"" ],
      debug = Some (Task.Poly_debug.Record {
          msg = ''
          Don't know which network provisioner to configure.

        ''
      })
    }
]
