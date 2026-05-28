-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , `assert` : Optional ({ that : List Text })
    , check_mode : Optional Bool
    , import_tasks : Optional Text
    , when : Optional Text
  }
    , default =
        { `assert` = None ({ that : List Text })
    , check_mode = None Bool
    , import_tasks = None Text
    , when = None Text
  }
    }

in  [
    Entry::{
      name = "Check parameters",
      `assert` = Some {
        that = [
          "timer_state in ('started', 'stopped', 'absent')"
        , "timer_name is defined"
        , "timer_config is defined"
        , "timer_service is defined"
      ]
    },
      check_mode = Some False
    }
  , Entry::{
      name = "Install timer and service",
      import_tasks = Some "setup.yml",
      when = Some "timer_state != 'absent'"
    }
  , Entry::{
      name = "Remove timer and service",
      import_tasks = Some "remove.yml",
      when = Some "timer_state == 'absent'"
    }
]
