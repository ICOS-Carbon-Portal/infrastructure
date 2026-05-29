-- Auto-generated from ../../../../devops/roles/icos.fail2ban/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install fail2ban",
      apt = Some {
        name = Some [ "fail2ban" ],
        state = Some "present",
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
      name = Some "Enable fail2ban",
      service = Some (Task.Poly_service.Record { name = "fail2ban", state = "started", enabled = Some True })
    }
]
