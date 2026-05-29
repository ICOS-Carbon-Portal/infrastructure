-- Auto-generated from ../devops/vm-postgis.yml

let Play =
    { Type =
        { hosts : Text
    , roles : List ({ name : Optional Text, tags : Text, role : Text, lxd_vm_name : Optional Text, lxd_vm_root_size : Optional Text, lxd_vm_config : Optional ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }) })
    , tasks : Optional (List ({ include_role : Optional (< Record : { name : Text, tasks_from : Text } | Str : Text >), tags : Text, vars : Optional ({ postgresql_postgis_enable : Optional Bool, postgresql_postgres_password : Optional Text, postgresql_listen_addresses : Optional Text, postgresql_pg_stat_enable : Optional Bool, postgresql_backup_script : Optional Text, postgis_bbclient_name : Optional Text }), name : Optional Text, postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), become : Optional Bool, become_user : Optional Text, block : Optional (List ({ name : Text, postgresql_user : Optional ({ db : Text, name : Text, password : Text }), loop : Optional Text, postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text }) })) }))
  }
    , default =
        { tasks = None (List ({ include_role : Optional (< Record : { name : Text, tasks_from : Text } | Str : Text >), tags : Text, vars : Optional ({ postgresql_postgis_enable : Optional Bool, postgresql_postgres_password : Optional Text, postgresql_listen_addresses : Optional Text, postgresql_pg_stat_enable : Optional Bool, postgresql_backup_script : Optional Text, postgis_bbclient_name : Optional Text }), name : Optional Text, postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), become : Optional Bool, become_user : Optional Text, block : Optional (List ({ name : Text, postgresql_user : Optional ({ db : Text, name : Text, password : Text }), loop : Optional Text, postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text }) })) }))
  }
    }

in  [
    Play::{
      hosts = "postgis_server",
      roles = let Role =
        { Type =
            { name : Optional Text
        , tags : Text
        , role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text })
      }
        , default =
            { name = None Text
        , lxd_vm_name = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text })
      }
        }

    in  [
        Role::{
          name = Some "Create the postgis VM",
          tags = "vm",
          role = "icos.lxd_vm",
          lxd_vm_name = Some "postgis",
          lxd_vm_root_size = Some "50GB",
          lxd_vm_config = Some { `security.nesting` = "true", `limits.cpu` = "4", `limits.memory` = "10GB" }
        }
    ]
    }
  , Play::{
      hosts = "postgis_host",
      roles = let Role =
        { Type =
            { name : Optional Text
        , tags : Text
        , role : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text })
      }
        , default =
            { name = None Text
        , lxd_vm_name = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text })
      }
        }

    in  [
        Role::{ tags = "guest", role = "icos.lxd_guest" }
      , Role::{ tags = "postgis", role = "icos.postgis" }
    ],
      tasks = Some [
        {
          include_role = Some ((< Record : { name : Text, tasks_from : Text } | Str : Text >).Str "name=icos.postgresql"),
          tags = "postgresql",
          vars = Some {
            postgresql_postgis_enable = Some True
          , postgresql_postgres_password = Some "{{ postgis_admin_pass }}"
          , postgresql_listen_addresses = Some "'*'"
          , postgresql_pg_stat_enable = Some True
          , postgresql_backup_script = None Text
          , postgis_bbclient_name = None Text
        },
          name = None Text,
          postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }),
          become = None Bool,
          become_user = None Text,
          block = None (List ({ name : Text, postgresql_user : Optional ({ db : Text, name : Text, password : Text }), loop : Optional Text, postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text }) }))
        }
      , {
          include_role = Some ((< Record : { name : Text, tasks_from : Text } | Str : Text >).Record { name = "icos.postgresql", tasks_from = "backup" }),
          tags = "backup",
          vars = Some {
            postgresql_postgis_enable = None Bool
          , postgresql_postgres_password = None Text
          , postgresql_listen_addresses = None Text
          , postgresql_pg_stat_enable = None Bool
          , postgresql_backup_script = Some "backup-dumpall-bbclient"
          , postgis_bbclient_name = Some "postgis"
        },
          name = Some "Install backup for postgresql",
          postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }),
          become = None Bool,
          become_user = None Text,
          block = None (List ({ name : Text, postgresql_user : Optional ({ db : Text, name : Text, password : Text }), loop : Optional Text, postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text }) }))
        }
      , {
          include_role = None (< Record : { name : Text, tasks_from : Text } | Str : Text >),
          tags = "hba",
          vars = None ({ postgresql_postgis_enable : Optional Bool, postgresql_postgres_password : Optional Text, postgresql_listen_addresses : Optional Text, postgresql_pg_stat_enable : Optional Bool, postgresql_backup_script : Optional Text, postgis_bbclient_name : Optional Text }),
          name = Some "Allow postgres user to connect from same subnet",
          postgresql_pg_hba = Some {
            dest = "{{ postgresql_hba_file }}"
          , users = "postgres"
          , source = "samenet"
          , method = "md5"
          , contype = "hostssl"
        },
          become = None Bool,
          become_user = None Text,
          block = None (List ({ name : Text, postgresql_user : Optional ({ db : Text, name : Text, password : Text }), loop : Optional Text, postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }), `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text }) }))
        }
      , {
          include_role = None (< Record : { name : Text, tasks_from : Text } | Str : Text >),
          tags = "cplog",
          vars = None ({ postgresql_postgis_enable : Optional Bool, postgresql_postgres_password : Optional Text, postgresql_listen_addresses : Optional Text, postgresql_pg_stat_enable : Optional Bool, postgresql_backup_script : Optional Text, postgis_bbclient_name : Optional Text }),
          name = None Text,
          postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text }),
          become = Some True,
          become_user = Some "postgres",
          block = Some (let Entry =
            { Type =
                { name : Text
            , postgresql_user : Optional ({ db : Text, name : Text, password : Text })
            , loop : Optional Text
            , postgresql_pg_hba : Optional ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
            , `community.postgresql.postgresql_ext` : Optional ({ name : Text, db : Text, schema : Text })
          }
            , default =
                { postgresql_user = None ({ db : Text, name : Text, password : Text })
            , loop = None Text
            , postgresql_pg_hba = None ({ dest : Text, users : Text, source : Text, method : Text, contype : Text })
            , `community.postgresql.postgresql_ext` = None ({ name : Text, db : Text, schema : Text })
          }
            }

        in  [
            Entry::{
              name = "Create postgres cplog users",
              postgresql_user = Some { db = "cplog", name = "{{ item.username }}", password = "{{ item.password }}" },
              loop = Some "{{ postgis_cplog_users }}"
            }
          , Entry::{
              name = "Allow users to connect from same subnet",
              loop = Some "{{ postgis_cplog_users }}",
              postgresql_pg_hba = Some {
                dest = "{{ postgresql_hba_file }}"
              , users = "{{ item.username }}"
              , source = "samenet"
              , method = "md5"
              , contype = "hostssl"
            }
            }
          , Entry::{
              name = "Add the pg_stat_statements extension",
              `community.postgresql.postgresql_ext` = Some { name = "pg_stat_statements", db = "cplog", schema = "public" }
            }
        ])
        }
    ]
    }
]
