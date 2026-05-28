-- Auto-generated from core.yml

let Play =
    { Type =
        { hosts : Text
    , tasks : Optional (List ({ name : Text, tags : List Text, import_role : { name : Text, tasks_from : Text }, when : Optional Text }))
    , vars : Optional ({ jre_apt_package : Text, java_path : Text })
    , pre_tasks : Optional (List ({ name : Text, apt : Optional ({ name : Text }), tags : Optional Text, import_role : Optional ({ name : Text, tasks_from : Text }) }))
    , roles : Optional (List ({ role : Text, tags : Optional Text, when : Optional Text }))
  }
    , default =
        { tasks = None (List ({ name : Text, tags : List Text, import_role : { name : Text, tasks_from : Text }, when : Optional Text }))
    , vars = None ({ jre_apt_package : Text, java_path : Text })
    , pre_tasks = None (List ({ name : Text, apt : Optional ({ name : Text }), tags : Optional Text, import_role : Optional ({ name : Text, tasks_from : Text }) }))
    , roles = None (List ({ role : Text, tags : Optional Text, when : Optional Text }))
  }
    }

in  [
    Play::{
      hosts = "core_server",
      tasks = Some [
        {
          name = "Setup cpmeta proxy",
          tags = [ "proxy", "cpmeta_proxy" ],
          import_role = { name = "icos.cpmeta", tasks_from = "proxy.yml" },
          when = None Text
        }
      , {
          name = "Setup cpdata proxy",
          tags = [ "proxy", "cpdata_proxy" ],
          import_role = { name = "icos.cpdata", tasks_from = "proxy.yml" },
          when = None Text
        }
      , {
          name = "Setup cpauth proxy",
          tags = [ "proxy", "cpauth_proxy" ],
          import_role = { name = "icos.cpauth", tasks_from = "proxy.yml" },
          when = Some "cpauth_domains is defined"
        }
      , {
          name = "Setup restheart proxy",
          tags = [ "proxy", "restheart_proxy" ],
          import_role = { name = "icos.restheart", tasks_from = "proxy.yml" },
          when = None Text
        }
      , {
          name = "Setup doi proxy",
          tags = [ "proxy", "doi_proxy" ],
          import_role = { name = "icos.doi", tasks_from = "proxy.yml" },
          when = Some "doi_certbot_name is defined"
        }
    ]
    }
  , Play::{
      hosts = "core_host",
      vars = Some {
        jre_apt_package = "openjdk-21-jre-headless"
      , java_path = "/usr/lib/jvm/java-21-openjdk-amd64/bin/java"
    },
      pre_tasks = Some [
        {
          name = "Install jre",
          apt = Some { name = "{{ jre_apt_package }}" },
          tags = None Text,
          import_role = None ({ name : Text, tasks_from : Text })
        }
      , {
          name = "Setup rdflog",
          apt = None ({ name : Text }),
          tags = Some "rdflog",
          import_role = Some { name = "icos.rdflog", tasks_from = "setup.yml" }
        }
      , {
          name = "Setup rdflog backup",
          apt = None ({ name : Text }),
          tags = Some "rdflog_backup",
          import_role = Some { name = "icos.rdflog", tasks_from = "backup.yml" }
        }
    ],
      roles = Some [
        { role = "icos.postgis", tags = Some "postgis", when = None Text }
      , { role = "icos.restheart", tags = None Text, when = None Text }
      , { role = "icos.cpmeta", tags = None Text, when = None Text }
      , { role = "icos.cpdata", tags = None Text, when = None Text }
      , { role = "icos.cpauth", tags = None Text, when = Some "cpauth_envries is defined" }
      , { role = "icos.doi", tags = None Text, when = None Text }
      , {
          role = "icos.virtuoso",
          tags = Some "virtuoso",
          when = Some "virtuoso_enable | default(False)"
        }
    ]
    }
]
