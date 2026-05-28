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
    Item::{ import_tasks = "install.yml", tags = "telegraf_install" }
  , Item::{
      import_tasks = "smart.yml",
      tags = "telegraf_smart",
      when = Some "telegraf_smart_enable"
    }
  , Item::{ import_tasks = "config.yml", tags = "telegraf_config" }
  , Item::{ import_tasks = "just.yml", tags = "telegraf_just" }
]
