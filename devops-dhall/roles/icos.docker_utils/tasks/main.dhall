-- Auto-generated from main.yml

let Item =
    { Type =
        { when : Optional Text
    , name : Optional Text
    , debug : Optional ({ msg : Text })
    , import_tasks : Optional Text
    , tags : Optional Text
  }
    , default =
        { when = None Text
    , name = None Text
    , debug = None ({ msg : Text })
    , import_tasks = None Text
    , tags = None Text
  }
    }

in  [
    Item::{
      when = Some "dive_architecture in (\"armv6l\", \"armv7l\")",
      name = Some "Architecture is not supported",
      debug = Some { msg = "dive is not supported on {{ dive_architecture }}" }
    }
  , Item::{
      when = Some "dive_architecture not in (\"armv6l\", \"armv7l\")",
      import_tasks = Some "dive.yml",
      tags = Some "dive"
    }
  , Item::{ import_tasks = Some "ctop.yml", tags = Some "ctop" }
  , Item::{ import_tasks = Some "lazydocker.yml", tags = Some "lazydocker" }
]
