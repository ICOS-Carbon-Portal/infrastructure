-- Auto-generated from ../devops/cpmeta.yml

let Play =
    { Type =
        { hosts : Text
    , tags : Text
    , tasks : Optional (List ({ name : Text, tags : Text, import_role : { name : Text, tasks_from : Text } }))
    , roles : Optional (List ({ role : Text }))
  }
    , default =
        { tasks = None (List ({ name : Text, tags : Text, import_role : { name : Text, tasks_from : Text } }))
    , roles = None (List ({ role : Text }))
  }
    }

in  [
    Play::{
      hosts = "core_server",
      tags = "server",
      tasks = Some [
        {
          name = "Setup cpmeta proxy"
        , tags = "proxy"
        , import_role = { name = "icos.cpmeta", tasks_from = "proxy.yml" }
      }
    ]
    }
  , Play::{
      hosts = "core_host",
      tags = "host",
      roles = Some [
        { role = "icos.cpmeta" }
    ]
    }
]
