-- Auto-generated from ../../../../devops/roles/icos.wireguard/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml" }
  , Task::{ import_tasks = Some "keys.yml" }
  , Task::{ import_tasks = Some "reresolve.yml" }
  , Task::{
      name = Some "Install wg(1) overlay",
      copy = Some {
        dest = "/usr/local/bin/wg",
        mode = Some "+x",
        content = None Text,
        src = Some "wg.py",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
