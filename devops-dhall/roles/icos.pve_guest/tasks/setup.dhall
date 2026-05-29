-- Auto-generated from ../../../../devops/roles/icos.pve_guest/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install qemu-guest-agent",
      apt = Some {
        name = Some [ "qemu-guest-agent" ],
        state = None Text,
        update_cache = Some True,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    },
      notify = Some [ "reboot" ]
    }
  , Task::{
      name = Some "Set timezone to Europe/Stockholm",
      timezone = Some { name = "Europe/Stockholm" },
      notify = Some [ "restart cron" ]
    }
  , Task::{
      name = Some "Generate locale",
      locale_gen = Some { name = "{{ item }}", state = "present" },
      loop = Some (Task.Poly_loop.Texts [ "en_US.UTF-8", "sv_SE.UTF-8" ])
    }
  , Task::{
      name = Some "Upgrade everything",
      apt = Some {
        name = None ((List Text)),
        state = None Text,
        update_cache = Some True,
        upgrade = Some "True",
        deb = None Text,
        purge = None Bool,
        autoclean = Some True,
        autoremove = Some True,
        cache_valid_time = None Text,
        install_recommends = None Bool
    },
      when = Some [ "upgrade_everything" ],
      notify = Some [ "reboot" ]
    }
]
