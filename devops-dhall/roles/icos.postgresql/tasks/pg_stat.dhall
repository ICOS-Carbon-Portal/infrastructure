-- Auto-generated from pg_stat.yml

let Item =
    { Type =
        { become : Optional Bool
    , become_user : Optional Text
    , block : Optional (List ({ name : Text, `community.postgresql.postgresql_set` : { name : Text, value : Text }, register : Text }))
    , name : Optional Text
    , systemd : Optional ({ name : Text, state : Text })
    , when : Optional Text
  }
    , default =
        { become = None Bool
    , become_user = None Text
    , block = None (List ({ name : Text, `community.postgresql.postgresql_set` : { name : Text, value : Text }, register : Text }))
    , name = None Text
    , systemd = None ({ name : Text, state : Text })
    , when = None Text
  }
    }

in  [
    Item::{
      become = Some True,
      become_user = Some "postgres",
      block = Some [
        {
          name = "Add pg_stat_statements to postgresql shared_preload_libraries"
        , `community.postgresql.postgresql_set` = { name = "shared_preload_libraries", value = "pg_stat_statements" }
        , register = "_set"
      }
    ]
    }
  , Item::{
      name = Some "Restart postgresql",
      systemd = Some { name = "postgresql", state = "restarted" },
      when = Some "_set.changed and _set.restart_required"
    }
]
