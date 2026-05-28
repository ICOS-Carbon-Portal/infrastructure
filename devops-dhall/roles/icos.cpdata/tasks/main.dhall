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
    Item::{ import_tasks = "setup.yml", tags = "cpdata_setup" }
  , Item::{
      import_tasks = "deploy.yml",
      tags = "cpdata_deploy",
      when = Some "cpdata_jar_file is defined"
    }
]
