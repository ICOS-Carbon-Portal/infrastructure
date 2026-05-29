-- Auto-generated from ../devops/restheart.yml

let Play =
    { Type =
        { hosts : Text
    , tags : Text
    , tasks : Optional (List ({ name : Text, tags : Text, import_role : { name : Text, tasks_from : Text } }))
    , roles : Optional (List ({ role : Text, tags : Text }))
  }
    , default =
        { tasks = None (List ({ name : Text, tags : Text, import_role : { name : Text, tasks_from : Text } }))
    , roles = None (List ({ role : Text, tags : Text }))
  }
    }

in  [
    Play::{
      hosts = "core_server",
      tags = "server",
      tasks = Some [
        {
          name = "Setup restheart proxy"
        , tags = "proxy"
        , import_role = { name = "icos.restheart", tasks_from = "proxy.yml" }
      }
    ]
    }
  , Play::{
      hosts = "core_host",
      tags = "host",
      roles = Some [
        { role = "icos.restheart", tags = "restheart" }
    ]
    }
]
