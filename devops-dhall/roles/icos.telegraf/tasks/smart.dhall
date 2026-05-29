-- Auto-generated from ../../../../devops/roles/icos.telegraf/tasks/smart.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install smartmontools",
      apt = Some {
        name = Some [ "smartmontools" ],
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
      name = Some "Allow the telegraf user to sudo /usr/sbin/smartctl",
      `community.general.sudoers` = Some {
        name = "allow-telegraf-smart",
        state = "present",
        user = "telegraf",
        commands = "/usr/sbin/smartctl"
    }
    }
]
