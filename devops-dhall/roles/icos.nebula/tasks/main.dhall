-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : List Text
    , when : Optional (List Text)
  }
    , default =
        { when = None (List Text)
  }
    }

in  [
    Item::{ import_tasks = "install.yml", tags = [ "nebula_install" ] }
  , Item::{
      import_tasks = "ssh.yml",
      tags = [ "nebula_ssh", "nebula_config" ],
      when = Some [ "nebula_ssh_enable", "nebula_ssh_public is not defined" ]
    }
  , Item::{ import_tasks = "just.yml", tags = [ "nebula_just" ] }
  , Item::{ import_tasks = "ca.yml", tags = [ "nebula_ca" ] }
  , Item::{ import_tasks = "cert.yml", tags = [ "nebula_cert" ] }
  , Item::{ import_tasks = "iptables.yml", tags = [ "nebula_iptables" ] }
  , Item::{ import_tasks = "config.yml", tags = [ "nebula_config" ] }
  , Item::{ import_tasks = "service.yml", tags = [ "nebula_service" ] }
  , Item::{ import_tasks = "hosts.yml", tags = [ "nebula_hosts" ] }
  , Item::{
      import_tasks = "resolve.yml",
      tags = [ "nebula_resolve" ],
      when = Some [ "nebula_resolve_enable" ]
    }
  , Item::{ import_tasks = "test.yml", tags = [ "nebula_test", "nebula_resolve" ] }
]
