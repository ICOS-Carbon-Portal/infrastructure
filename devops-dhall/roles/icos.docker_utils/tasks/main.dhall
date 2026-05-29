-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      when = Some [ "dive_architecture in (\"armv6l\", \"armv7l\")" ],
      name = Some "Architecture is not supported",
      debug = Some { msg = "dive is not supported on {{ dive_architecture }}" }
    }
  , Task::{
      when = Some [ "dive_architecture not in (\"armv6l\", \"armv7l\")" ],
      import_tasks = Some "dive.yml",
      tags = Some [ "dive" ]
    }
  , Task::{ import_tasks = Some "ctop.yml", tags = Some [ "ctop" ] }
  , Task::{ import_tasks = Some "lazydocker.yml", tags = Some [ "lazydocker" ] }
]
