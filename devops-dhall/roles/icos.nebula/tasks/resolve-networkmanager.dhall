-- Auto-generated from resolve-networkmanager.yml

let Item =
    { Type =
        { name : Optional Text
    , systemd : Optional ({ name : Text })
    , register : Optional Text
    , when : Optional Text
    , fail : Optional ({ msg : Text })
    , import_tasks : Optional Text
    , notify : Optional Text
  }
    , default =
        { name = None Text
    , systemd = None ({ name : Text })
    , register = None Text
    , when = None Text
    , fail = None ({ msg : Text })
    , import_tasks = None Text
    , notify = None Text
  }
    }

in  [
    Item::{
      name = Some "Query systemd for systemd-networkd",
      systemd = Some { name = "systemd-networkd" },
      register = Some "_networkd"
    }
  , Item::{
      name = Some "Warn about NetworkManage+systemd-networkd",
      when = Some "_networkd.status.ActiveState == \"active\"",
      fail = Some {
        msg = ''
        We're not setup for provisioning NetworkManager+systemd-networkd

      ''
    }
    }
  , Item::{ import_tasks = Some "resolve-dnsmasq.yml", notify = Some "restart NetworkManager" }
]
