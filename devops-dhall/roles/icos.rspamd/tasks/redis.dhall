-- Auto-generated from redis.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text, state : Text })
    , copy : Optional ({ dest : Text, content : Text })
    , notify : Optional Text
  }
    , default =
        { apt = None ({ name : Text, state : Text })
    , copy = None ({ dest : Text, content : Text })
    , notify = None Text
  }
    }

in  [
    Task::{ name = "Install redis", apt = Some { name = "redis", state = "present" } }
  , Task::{
      name = "Configure rspamd to use redis",
      copy = Some {
        dest = "/etc/rspamd/local.d/redis.conf"
      , content = ''
        servers = "127.0.0.1";

      ''
    },
      notify = Some "restart rspamd"
    }
]
