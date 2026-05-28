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
    Item::{ import_tasks = "setup.yml", tags = "jupyter_setup" }
  , Item::{ import_tasks = "registry.yml", tags = "jupyter_registry" }
  , Item::{
      import_tasks = "jusers.yml",
      tags = "jupyter_jusers",
      when = Some "jupyter_jusers_enable"
    }
  , Item::{ import_tasks = "just.yml", tags = "jupyter_just" }
]
