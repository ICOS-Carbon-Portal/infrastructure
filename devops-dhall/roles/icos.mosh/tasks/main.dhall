-- Auto-generated from ../../../../devops/roles/icos.mosh/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install mosh",
      apt = Some {
        name = Some [ "mosh" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Allow mosh through firewall",
      iptables_raw = Some {
        name = "allow_mosh",
        rules = Some "-A INPUT -p udp -m multiport --dports 60000:61000 -j ACCEPT -m comment --comment 'mosh'",
        table = None Text,
        state = None Text,
        weight = None Natural
    },
      when = Some [ "mosh_add_firewall" ]
    }
]
