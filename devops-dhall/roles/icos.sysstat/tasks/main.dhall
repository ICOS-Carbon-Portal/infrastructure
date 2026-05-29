-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install sysstat",
      apt = Some {
        name = Some [ "sysstat" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Enable sysstat",
      lineinfile = Some {
        path = "/etc/default/sysstat"
      , line = Some "ENABLED=\"true\""
      , state = Some "present"
      , regex = None Text
      , regexp = Some "^ENABLED="
      , create = None Bool
      , owner = None Text
      , group = None Text
      , insertafter = None Text
      , mode = None Natural
      , insertbefore = None Text
    }
    }
  , Task::{
      name = Some "Start sysstat service",
      systemd = Some {
        name = Some "sysstat"
      , state = Some "started"
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
]
