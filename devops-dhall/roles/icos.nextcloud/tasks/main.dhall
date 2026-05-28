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
    Item::{ import_tasks = "setup.yml", tags = "nextcloud_setup" }
  , Item::{ import_tasks = "nginx.yml", tags = "nextcloud_nginx" }
  , Item::{
      import_tasks = "prometheus.yml",
      tags = "nextcloud_prometheus",
      when = Some "nextcloud_exporter_pass is defined"
    }
  , Item::{ import_tasks = "just.yml", tags = "nextcloud_just" }
]
