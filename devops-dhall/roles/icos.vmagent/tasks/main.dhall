-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml", tags = Some [ "vmagent_install" ] }
  , Task::{ import_tasks = Some "systemd.yml", tags = Some [ "vmagent_systemd" ] }
  , Task::{
      when = Some [ "vmagent_proxy != \"disabled\"" ],
      import_tasks = Some "proxy.yml",
      tags = Some [ "vmagent_proxy" ]
    }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "vmagent_just" ] }
]
