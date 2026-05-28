-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ update_cache : Bool, name : Optional (List Text), upgrade : Optional Bool, autoclean : Optional Bool, autoremove : Optional Bool })
    , notify : Optional Text
    , timezone : Optional ({ name : Text })
    , locale_gen : Optional ({ name : Text, state : Text })
    , loop : Optional (List Text)
    , when : Optional Text
  }
    , default =
        { apt = None ({ update_cache : Bool, name : Optional (List Text), upgrade : Optional Bool, autoclean : Optional Bool, autoremove : Optional Bool })
    , notify = None Text
    , timezone = None ({ name : Text })
    , locale_gen = None ({ name : Text, state : Text })
    , loop = None (List Text)
    , when = None Text
  }
    }

in  [
    Task::{
      name = "Install qemu-guest-agent",
      apt = Some {
        update_cache = True
      , name = Some [ "qemu-guest-agent" ]
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
    },
      notify = Some "reboot"
    }
  , Task::{
      name = "Set timezone to Europe/Stockholm",
      notify = Some "restart cron",
      timezone = Some { name = "Europe/Stockholm" }
    }
  , Task::{
      name = "Generate locale",
      locale_gen = Some { name = "{{ item }}", state = "present" },
      loop = Some [ "en_US.UTF-8", "sv_SE.UTF-8" ]
    }
  , Task::{
      name = "Upgrade everything",
      apt = Some {
        update_cache = True
      , name = None (List Text)
      , upgrade = Some True
      , autoclean = Some True
      , autoremove = Some True
    },
      notify = Some "reboot",
      when = Some "upgrade_everything"
    }
]
