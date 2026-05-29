-- Auto-generated from ../../devops/fixes/downtime-move-cpmeta.yml

let Play =
    { Type =
        { hosts : Text
    , vars_files : Text
    , tasks : Optional (List ({ name : Text, tags : Optional Text, delegate_to : Optional Text, become : Optional Bool, file : Optional ({ path : Text, state : Text }), loop : Optional (List Text), `ansible.posix.synchronize` : Optional ({ mode : Text, copy_links : Optional Bool, src : Text, dest : Text, rsync_opts : Optional (List Text), owner : Optional Bool, group : Optional Bool }), `ansible.builtin.shell` : Optional Text, args : Optional ({ chdir : Text, creates : Text, executable : Text }) }))
    , vars : Optional ({ coreapp_bind_addr : Text, cpmeta_backup_enable : Bool, cpmeta_readonly_mode : Bool })
    , handlers : Optional (List ({ name : Text, systemd : { name : Text, state : Text } }))
    , pre_tasks : Optional (List ({ name : Text, tags : Optional Text, `ansible.posix.synchronize` : Optional ({ mode : Optional Text, src : Text, dest : Text, owner : Bool, group : Bool, perms : Optional Bool, rsync_opts : Optional (List Text), delete : Optional Bool }), notify : Optional Text, file : Optional ({ path : Text, mode : Natural }) }))
    , roles : Optional (List ({ role : Text, tags : Text, rdflog_postgres_version : Optional Natural, rdflog_rep_pass : Optional Text, rdflog_restore_file : Optional Text, cpmeta_filestorage_target : Optional Text, cpmeta_jar_file : Optional Text, cpmeta_config_files : Optional (List Text) }))
  }
    , default =
        { tasks = None (List ({ name : Text, tags : Optional Text, delegate_to : Optional Text, become : Optional Bool, file : Optional ({ path : Text, state : Text }), loop : Optional (List Text), `ansible.posix.synchronize` : Optional ({ mode : Text, copy_links : Optional Bool, src : Text, dest : Text, rsync_opts : Optional (List Text), owner : Optional Bool, group : Optional Bool }), `ansible.builtin.shell` : Optional Text, args : Optional ({ chdir : Text, creates : Text, executable : Text }) }))
    , vars = None ({ coreapp_bind_addr : Text, cpmeta_backup_enable : Bool, cpmeta_readonly_mode : Bool })
    , handlers = None (List ({ name : Text, systemd : { name : Text, state : Text } }))
    , pre_tasks = None (List ({ name : Text, tags : Optional Text, `ansible.posix.synchronize` : Optional ({ mode : Optional Text, src : Text, dest : Text, owner : Bool, group : Bool, perms : Optional Bool, rsync_opts : Optional (List Text), delete : Optional Bool }), notify : Optional Text, file : Optional ({ path : Text, mode : Natural }) }))
    , roles = None (List ({ role : Text, tags : Text, rdflog_postgres_version : Optional Natural, rdflog_rep_pass : Optional Text, rdflog_restore_file : Optional Text, cpmeta_filestorage_target : Optional Text, cpmeta_jar_file : Optional Text, cpmeta_config_files : Optional (List Text) }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      vars_files = "vars/downtime.yml",
      tasks = Some [
        {
          name = "Create local certificate directories",
          tags = Some "nginx",
          delegate_to = Some "localhost",
          become = Some False,
          file = Some { path = "{{ item }}", state = "directory" },
          loop = Some [ "{{ local_cert_dir }}", "{{ local_conf_dir }}" ],
          `ansible.posix.synchronize` = None ({ mode : Text, copy_links : Optional Bool, src : Text, dest : Text, rsync_opts : Optional (List Text), owner : Optional Bool, group : Optional Bool }),
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text, creates : Text, executable : Text })
        }
      , {
          name = "Pull certificates",
          tags = Some "nginx",
          delegate_to = None Text,
          become = None Bool,
          file = None ({ path : Text, state : Text }),
          loop = None (List Text),
          `ansible.posix.synchronize` = Some {
            mode = "pull"
          , copy_links = Some True
          , src = ''
            /etc/letsencrypt/live/{{ "{" + ",".join(certificates) + "}" }}

          ''
          , dest = "{{ local_cert_dir }}/"
          , rsync_opts = None (List Text)
          , owner = None Bool
          , group = None Bool
        },
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text, creates : Text, executable : Text })
        }
      , {
          name = "Pull configuration",
          tags = Some "nginx",
          delegate_to = None Text,
          become = None Bool,
          file = None ({ path : Text, state : Text }),
          loop = None (List Text),
          `ansible.posix.synchronize` = Some {
            mode = "pull"
          , copy_links = Some True
          , src = ''
            /etc/nginx/{{ "{" + ",".join(configurations) + "}" }}

          ''
          , dest = "{{ local_conf_dir }}"
          , rsync_opts = Some [ "--mkpath" ]
          , owner = None Bool
          , group = None Bool
        },
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text, creates : Text, executable : Text })
        }
      , {
          name = "Pull cpmeta.jar",
          tags = Some "cpmeta",
          delegate_to = None Text,
          become = None Bool,
          file = None ({ path : Text, state : Text }),
          loop = None (List Text),
          `ansible.posix.synchronize` = Some {
            mode = "pull"
          , copy_links = Some True
          , src = "/home/cpmeta/cpmeta.jar"
          , dest = "{{ local_tmp }}/"
          , rsync_opts = None (List Text)
          , owner = None Bool
          , group = None Bool
        },
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text, creates : Text, executable : Text })
        }
      , {
          name = "Synchronize metaAppStorage",
          tags = None Text,
          delegate_to = None Text,
          become = None Bool,
          file = None ({ path : Text, state : Text }),
          loop = None (List Text),
          `ansible.posix.synchronize` = Some {
            mode = "pull"
          , copy_links = None Bool
          , src = "/disk/data/metaAppStorage"
          , dest = "{{ local_tmp }}/"
          , rsync_opts = None (List Text)
          , owner = Some False
          , group = Some False
        },
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text, creates : Text, executable : Text })
        }
      , {
          name = "Dump rdflog database",
          tags = Some "rdflog",
          delegate_to = None Text,
          become = None Bool,
          file = None ({ path : Text, state : Text }),
          loop = None (List Text),
          `ansible.posix.synchronize` = None ({ mode : Text, copy_links : Optional Bool, src : Text, dest : Text, rsync_opts : Optional (List Text), owner : Optional Bool, group : Optional Bool }),
          `ansible.builtin.shell` = Some "docker-compose exec -T db pg_dump -Cc --if-exists -d rdflog | gzip -c > /tmp/rdflog_dump.gz",
          args = Some {
            chdir = "/docker/rdflog"
          , creates = "/tmp/rdflog_dump.gz"
          , executable = "/bin/bash"
        }
        }
      , {
          name = "Pull rdflog_dump.gz",
          tags = Some "rdflog",
          delegate_to = None Text,
          become = None Bool,
          file = None ({ path : Text, state : Text }),
          loop = None (List Text),
          `ansible.posix.synchronize` = Some {
            mode = "pull"
          , copy_links = None Bool
          , src = "/tmp/rdflog_dump.gz"
          , dest = "{{ local_tmp }}/"
          , rsync_opts = None (List Text)
          , owner = Some False
          , group = Some False
        },
          `ansible.builtin.shell` = None Text,
          args = None ({ chdir : Text, creates : Text, executable : Text })
        }
    ]
    }
  , Play::{
      hosts = "icos1",
      vars_files = "vars/downtime.yml",
      vars = Some {
        coreapp_bind_addr = "127.0.0.1"
      , cpmeta_backup_enable = False
      , cpmeta_readonly_mode = True
    },
      handlers = Some [
        { name = "reload nginx", systemd = { name = "nginx", state = "reloaded" } }
    ],
      pre_tasks = Some [
        {
          name = "Push certificates",
          tags = Some "nginx",
          `ansible.posix.synchronize` = Some {
            mode = Some "push"
          , src = "{{ local_cert_dir }}/"
          , dest = "/etc/letsencrypt/live/"
          , owner = False
          , group = False
          , perms = Some False
          , rsync_opts = None (List Text)
          , delete = None Bool
        },
          notify = Some "reload nginx",
          file = None ({ path : Text, mode : Natural })
        }
      , {
          name = "Change access rights on /etc/letsencrypt/live",
          tags = Some "nginx",
          `ansible.posix.synchronize` = None ({ mode : Optional Text, src : Text, dest : Text, owner : Bool, group : Bool, perms : Optional Bool, rsync_opts : Optional (List Text), delete : Optional Bool }),
          notify = None Text,
          file = Some { path = "/etc/letsencrypt/live", mode = 448 }
        }
      , {
          name = "Push configuration",
          tags = Some "nginx",
          `ansible.posix.synchronize` = Some {
            mode = Some "push"
          , src = "{{ local_conf_dir }}/"
          , dest = "/etc/nginx/conf.d"
          , owner = False
          , group = False
          , perms = None Bool
          , rsync_opts = None (List Text)
          , delete = None Bool
        },
          notify = Some "reload nginx",
          file = None ({ path : Text, mode : Natural })
        }
      , {
          name = "Push rdflog dump",
          tags = Some "rdflog",
          `ansible.posix.synchronize` = Some {
            mode = None Text
          , src = "{{ local_tmp }}/rdflog_dump.gz"
          , dest = "/tmp/"
          , owner = False
          , group = False
          , perms = None Bool
          , rsync_opts = None (List Text)
          , delete = None Bool
        },
          notify = None Text,
          file = None ({ path : Text, mode : Natural })
        }
      , {
          name = "Push metaAppStorage",
          tags = None Text,
          `ansible.posix.synchronize` = Some {
            mode = None Text
          , src = "{{ local_tmp }}/metaAppStorage"
          , dest = "/home/cpmeta/"
          , owner = False
          , group = False
          , perms = None Bool
          , rsync_opts = Some [ "--mkpath" ]
          , delete = Some False
        },
          notify = None Text,
          file = None ({ path : Text, mode : Natural })
        }
    ],
      roles = Some [
        {
          role = "icos.rdflog",
          tags = "rdflog",
          rdflog_postgres_version = Some 10,
          rdflog_rep_pass = Some "{{ vault_rdflog_rep_pass }}",
          rdflog_restore_file = Some "{{ local_tmp }}/rdflog_dump.gz",
          cpmeta_filestorage_target = None Text,
          cpmeta_jar_file = None Text,
          cpmeta_config_files = None (List Text)
        }
      , {
          role = "icos.cpmeta",
          tags = "cpmeta",
          rdflog_postgres_version = None Natural,
          rdflog_rep_pass = None Text,
          rdflog_restore_file = None Text,
          cpmeta_filestorage_target = Some "{{ cpmeta_home }}/metaAppStorage",
          cpmeta_jar_file = Some "{{ local_tmp }}/cpmeta.jar",
          cpmeta_config_files = Some [
            "application_production.conf"
          , "application_production_sensitive.conf"
          , "application_failover_amendment.conf"
        ]
        }
    ]
    }
]
