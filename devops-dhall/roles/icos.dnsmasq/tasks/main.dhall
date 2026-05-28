-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional Text
    , name : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool })
  }
    , default =
        { import_tasks = None Text
    , tags = None Text
    , name = None Text
    , systemd = None ({ name : Text, enabled : Bool })
  }
    }

in  [
    Item::{ import_tasks = Some "setup.yml", tags = Some "dnsmasq_setup" }
  , Item::{ import_tasks = Some "config.yml", tags = Some "dnsmasq_config" }
  , Item::{ import_tasks = Some "hosts.yml", tags = Some "dnsmasq_hosts" }
  , Item::{
      name = Some "Start and enable dnsmasq",
      systemd = Some { name = "{{ dnsmasq_service_name }}", enabled = True }
    }
]
