-- Auto-generated from ../../../../devops/roles/icos.bbserver/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "setup.yml", tags = Some [ "bbserver_setup" ] }
  , Task::{ import_tasks = Some "cli.yml", tags = Some [ "bbserver_cli" ] }
  , Task::{
      name = Some "Check whether {{ bbserver_textfiles }} exists",
      tags = Some [ "bbserver_monitor" ],
      stat = Some { path = "{{ bbserver_textfiles }}" },
      register = Some "_textfiles"
    }
  , Task::{
      import_tasks = Some "monitor.yml",
      tags = Some [ "bbserver_monitor" ],
      when = Some [ "_textfiles.stat.exists" ]
    }
]
