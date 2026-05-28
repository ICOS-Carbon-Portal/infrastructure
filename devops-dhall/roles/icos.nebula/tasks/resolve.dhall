-- Auto-generated from resolve.yml

let Item =
    { Type =
        { when : Text
    , include_tasks : Optional Text
    , debug : Optional ({ msg : Text })
  }
    , default =
        { include_tasks = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{ when = "nebula_resolve_type == \"probe\"", include_tasks = Some "resolve-probe.yml" }
  , Item::{
      when = "nebula_resolve_type == \"dnsmasq\"",
      include_tasks = Some "resolve-dnsmasq.yml"
    }
  , Item::{
      when = "nebula_resolve_type == \"NetworkManager\"",
      include_tasks = Some "resolve-networkmanager.yml"
    }
  , Item::{
      when = "nebula_resolve_type == \"systemd-networkd\"",
      include_tasks = Some "resolve-networkd.yml"
    }
  , Item::{
      when = "nebula_resolve_type == \"unknown\"",
      debug = Some {
        msg = ''
        Don't know which network provisioner to configure.

      ''
    }
    }
]
