-- Auto-generated from core_restore.yml

[
    {
      hosts = "core_host"
    , connection = "local"
    , tasks = [
        {
          name = "Make sure borg is installed",
          tags = [ "setup" ],
          import_role = { name = "icos.borg", tasks_from = None Text },
          vars = None ({ postgresql_backup_host : Optional Text, postgresql_backup_location : Optional Text, container_name : Optional Text, postgresql_user : Optional Text, postgresql_container_name : Optional Text, restheart_backup_host : Optional Text })
        }
      , {
          name = "Restore rdflog backup",
          tags = [ "rdflog" ],
          import_role = { name = "icos.postgresql", tasks_from = Some "restore.yml" },
          vars = Some {
            postgresql_backup_host = Some "{{ corebackup_host }}"
          , postgresql_backup_location = Some "{{ rdflog_backup_location }}"
          , container_name = Some "{{ rdflog_container_name }}"
          , postgresql_user = Some "{{ rdflog_user }}"
          , postgresql_container_name = Some "rdflog"
          , restheart_backup_host = None Text
        }
        }
      , {
          name = "Restore postgis backup",
          tags = [ "postgis" ],
          import_role = { name = "icos.postgresql", tasks_from = Some "restore.yml" },
          vars = Some {
            postgresql_backup_host = Some "{{ corebackup_host }}"
          , postgresql_backup_location = Some "{{ postgis_backup_location }}"
          , container_name = Some "{{ postgis_container_name }}"
          , postgresql_user = Some "{{ postgis_user }}"
          , postgresql_container_name = Some "postgis"
          , restheart_backup_host = None Text
        }
        }
      , {
          name = "Restore restheart backup",
          tags = [ "restheart" ],
          import_role = { name = "icos.restheart", tasks_from = Some "restore.yml" },
          vars = Some {
            postgresql_backup_host = None Text
          , postgresql_backup_location = None Text
          , container_name = None Text
          , postgresql_user = None Text
          , postgresql_container_name = None Text
          , restheart_backup_host = Some "{{ corebackup_host }}"
        }
        }
    ]
  }
]
