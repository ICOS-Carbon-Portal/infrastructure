-- Auto-generated from ../../../../devops/roles/icos.drupal/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some (Task.Poly_loop.Texts [ "website" ]),
      tags = Some [ "drupal", "drupal_nginx" ]
    }
  , Task::{
      name = Some "Include {{ website }} vars",
      include_vars = Some "{{ website }}-vars.yml",
      tags = Some [ "drupal", "drupal_nginx" ]
    }
  , Task::{
      name = Some "Include {{ website }} vault",
      include_vars = Some "{{ website }}-vault.yml",
      tags = Some [ "drupal", "drupal_nginx" ]
    }
  , Task::{
      name = Some "Include vars",
      include_vars = Some "drupal.yml",
      tags = Some [ "drupal", "drupal_nginx" ]
    }
  , Task::{ import_tasks = Some "nginx.yml", tags = Some [ "drupal_nginx" ] }
  , Task::{ import_tasks = Some "drupal.yml", tags = Some [ "drupal" ] }
  , Task::{ import_tasks = Some "backup.yml", tags = Some [ "drupal_backup" ] }
]
