-- Auto-generated from redis.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install redis",
      apt = Some {
        name = Some [ "redis" ]
      , state = Some "present"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Configure rspamd to use redis",
      copy = Some {
        src = None Text
      , dest = "/etc/rspamd/local.d/redis.conf"
      , mode = None Text
      , content = Some ''
        servers = "127.0.0.1";

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
]
