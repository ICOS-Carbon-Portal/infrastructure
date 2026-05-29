-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install qemu-guest-agent",
      apt = Some {
        name = Some [ "qemu-guest-agent" ]
      , state = None Text
      , update_cache = Some True
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
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
      loop = Some [ "en_US.UTF-8", "sv_SE.UTF-8" ]
    }
  , Task::{
      name = Some "Upgrade everything",
      apt = Some {
        name = None (List Text)
      , state = None Text
      , update_cache = Some True
      , deb = None Text
      , purge = None Bool
      , upgrade = Some True
      , autoclean = Some True
      , autoremove = Some True
      , cache_valid_time = None Text
      , install_recommends = None Bool
    },
      when = Some [ "upgrade_everything" ],
      notify = Some [ "reboot" ]
    }
]
