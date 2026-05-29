-- Auto-generated from ../../../../devops/roles/icos.timer2/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check parameters",
      `assert` = Some {
        that = [
          "timer_state in ('started', 'stopped', 'absent')"
        , "timer_name is defined"
        , "timer_config is defined"
        , "timer_service is defined"
      ],
        quiet = None Bool
    },
      check_mode = Some False
    }
  , Task::{
      name = Some "Install timer and service",
      import_tasks = Some "setup.yml",
      when = Some [ "timer_state != 'absent'" ]
    }
  , Task::{
      name = Some "Remove timer and service",
      import_tasks = Some "remove.yml",
      when = Some [ "timer_state == 'absent'" ]
    }
]
