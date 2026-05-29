-- Auto-generated from resolve.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      when = Some [ "nebula_resolve_type == \"probe\"" ],
      include_tasks = Some "resolve-probe.yml"
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"dnsmasq\"" ],
      include_tasks = Some "resolve-dnsmasq.yml"
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"NetworkManager\"" ],
      include_tasks = Some "resolve-networkmanager.yml"
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"systemd-networkd\"" ],
      include_tasks = Some "resolve-networkd.yml"
    }
  , Task::{
      when = Some [ "nebula_resolve_type == \"unknown\"" ],
      debug = Some {
        msg = ''
        Don't know which network provisioner to configure.

      ''
    }
    }
]
