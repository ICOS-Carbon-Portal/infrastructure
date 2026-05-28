-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , command : Optional Text
    , notify : Optional Text
    , service : Optional ({ name : Text, state : Text })
  }
    , default =
        { command = None Text
    , notify = None Text
    , service = None ({ name : Text, state : Text })
  }
    }

in  [
    Entry::{
      name = "reload nginx config",
      command = Some "nginx -t",
      notify = Some "really reload nginx config"
    }
  , Entry::{
      name = "really reload nginx config",
      service = Some { name = "nginx", state = "reloaded" }
    }
]
