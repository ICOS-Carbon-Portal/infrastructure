-- Auto-generated from ../../../../devops/roles/icos.sysstat/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install sysstat",
      apt = Some {
        name = Some [ "sysstat" ],
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
      name = Some "Enable sysstat",
      lineinfile = Some {
        path = "/etc/default/sysstat",
        regex = None Text,
        line = Some "ENABLED=\"true\"",
        state = Some "present",
        backrefs = None Bool,
        regexp = Some "^ENABLED=",
        create = None Bool,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Start sysstat service",
      systemd = Some {
        name = Some "sysstat",
        state = Some "started",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
