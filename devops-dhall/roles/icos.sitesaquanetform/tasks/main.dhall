-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , include_vars : Optional Text
    , tags : List Text
    , import_tasks : Optional Text
    , file : Optional ({ path : Text, state : Text, recurse : Bool })
  }
    , default =
        { name = None Text
    , include_vars = None Text
    , import_tasks = None Text
    , file = None ({ path : Text, state : Text, recurse : Bool })
  }
    }

in  [
    Item::{ name = Some "Include vars", include_vars = Some "vars.yml", tags = [ "always" ] }
  , Item::{ name = Some "Include vault", include_vars = Some "vault.yml", tags = [ "always" ] }
  , Item::{ tags = [ "nginx" ], import_tasks = Some "nginx.yml" }
  , Item::{
      name = Some "Create project directory",
      tags = [ "repo", "pull" ],
      file = Some { path = "{{ project_dir }}", state = "directory", recurse = True }
    }
  , Item::{ tags = [ "repo" ], import_tasks = Some "bitbucket.yml" }
  , Item::{ tags = [ "pull" ], import_tasks = Some "sitesaquanetform.yml" }
]
