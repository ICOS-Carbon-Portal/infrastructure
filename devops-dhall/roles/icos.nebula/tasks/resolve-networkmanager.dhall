-- Auto-generated from resolve-networkmanager.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Query systemd for systemd-networkd",
      systemd = Some {
        name = Some "systemd-networkd"
      , state = None Text
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    },
      register = Some "_networkd"
    }
  , Task::{
      when = Some [ "_networkd.status.ActiveState == \"active\"" ],
      name = Some "Warn about NetworkManage+systemd-networkd",
      fail = Some {
        msg = ''
        We're not setup for provisioning NetworkManager+systemd-networkd

      ''
    }
    }
  , Task::{ import_tasks = Some "resolve-dnsmasq.yml", notify = Some [ "restart NetworkManager" ] }
]
