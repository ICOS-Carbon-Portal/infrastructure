-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , loop : Optional (List Text)
    , tags : List Text
    , include_vars : Optional Text
    , import_tasks : Optional Text
  }
    , default =
        { name = None Text
    , fail = None ({ msg : Text })
    , when = None Text
    , loop = None (List Text)
    , include_vars = None Text
    , import_tasks = None Text
  }
    }

in  [
    Item::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [ "website" ],
      tags = [ "drupal", "drupal_nginx" ]
    }
  , Item::{
      name = Some "Include {{ website }} vars",
      tags = [ "drupal", "drupal_nginx" ],
      include_vars = Some "{{ website }}-vars.yml"
    }
  , Item::{
      name = Some "Include {{ website }} vault",
      tags = [ "drupal", "drupal_nginx" ],
      include_vars = Some "{{ website }}-vault.yml"
    }
  , Item::{
      name = Some "Include vars",
      tags = [ "drupal", "drupal_nginx" ],
      include_vars = Some "drupal.yml"
    }
  , Item::{ tags = [ "drupal_nginx" ], import_tasks = Some "nginx.yml" }
  , Item::{ tags = [ "drupal" ], import_tasks = Some "drupal.yml" }
  , Item::{ tags = [ "drupal_backup" ], import_tasks = Some "backup.yml" }
]
