-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ name = Some "Include vars", include_vars = Some "vars.yml", tags = Some [ "always" ] }
  , Task::{ name = Some "Include vault", include_vars = Some "vault.yml", tags = Some [ "always" ] }
  , Task::{ import_tasks = Some "nginx.yml", tags = Some [ "nginx" ] }
  , Task::{
      name = Some "Create project directory",
      file = Some {
        path = Some "{{ project_dir }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = Some True
      , src = None Text
    },
      tags = Some [ "repo", "pull" ]
    }
  , Task::{ import_tasks = Some "bitbucket.yml", tags = Some [ "repo" ] }
  , Task::{ import_tasks = Some "sitesaquanetform.yml", tags = Some [ "pull" ] }
]
