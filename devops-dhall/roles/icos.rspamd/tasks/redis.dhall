-- Auto-generated from ../../../../devops/roles/icos.rspamd/tasks/redis.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install redis",
      apt = Some {
        name = Some [ "redis" ],
        state = Some "present",
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Configure rspamd to use redis",
      copy = Some {
        dest = "/etc/rspamd/local.d/redis.conf",
        mode = None Text,
        content = Some ''
        servers = "127.0.0.1";

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "restart rspamd" ]
    }
]
