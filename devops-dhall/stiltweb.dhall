-- Auto-generated from stiltweb.yml

let Play =
    { Type =
        { hosts : Text
    , tags : Text
    , tasks : Optional (List ({ name : Text, tags : Text, import_role : { name : Text, tasks_from : Text } }))
    , vars : Optional ({ stiltweb_akka_hostname : Text })
    , roles : Optional (List ({ role : Text, tags : Text }))
  }
    , default =
        { tasks = None (List ({ name : Text, tags : Text, import_role : { name : Text, tasks_from : Text } }))
    , vars = None ({ stiltweb_akka_hostname : Text })
    , roles = None (List ({ role : Text, tags : Text }))
  }
    }

in  [
    Play::{
      hosts = "core_server",
      tags = "server",
      tasks = Some [
        {
          name = "Setup stiltweb proxy"
        , tags = "proxy"
        , import_role = { name = "icos.stiltweb", tasks_from = "nginx_proxy.yml" }
      }
    ]
    }
  , Play::{
      hosts = "core_host",
      tags = "host",
      vars = Some { stiltweb_akka_hostname = "fsicos2.nebula" },
      roles = Some [
        { role = "icos.stiltweb", tags = "stiltweb" }
    ]
    }
]
