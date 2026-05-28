-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : Text
    , when : Optional Text
  }
    , default =
        { when = None Text
  }
    }

in  [
    Item::{ import_tasks = "setup.yml", tags = "nginx_setup" }
  , Item::{ import_tasks = "certbot.yml", tags = "nginx_certbot" }
  , Item::{ import_tasks = "testing.yml", tags = "nginx_testing" }
  , Item::{
      import_tasks = "metrics.yml",
      tags = "nginx_metrics",
      when = Some "nginx_metrics_enable"
    }
]
