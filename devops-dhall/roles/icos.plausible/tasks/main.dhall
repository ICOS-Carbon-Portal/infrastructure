-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
    , copy : Optional ({ src : Text, dest : Text })
    , template : Optional ({ src : Text, dest : Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text })
    , include_tasks : Optional Text
    , when : Optional Text
  }
    , default =
        { name = None Text
    , file = None ({ path : Text, state : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
    , copy = None ({ src : Text, dest : Text })
    , template = None ({ src : Text, dest : Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text })
    , include_tasks = None Text
    , when = None Text
  }
    }

in  [
    Item::{
      name = Some "Create home directory",
      file = Some { path = "{{ plausible_home }}", state = "directory" }
    }
  , Item::{
      include_role = Some { name = "icos.nginxsite" },
      vars = Some {
        nginxsite_name = "plausible"
      , nginxsite_file = "plausible-nginx.conf"
      , nginxsite_domains = [ "{{ plausible_domain }}" ]
    }
    }
  , Item::{
      name = Some "Copy clickhouse-config.xml",
      copy = Some { src = "clickhouse-config.xml", dest = "{{ plausible_home }}/clickhouse/" }
    }
  , Item::{
      name = Some "Copy clickhouse-user-config.xml",
      copy = Some { src = "clickhouse-user-config.xml", dest = "{{ plausible_home }}/clickhouse/" }
    }
  , Item::{
      name = Some "Copy plausible-conf.env",
      template = Some { src = "plausible-conf.env", dest = "{{ plausible_home }}" }
    }
  , Item::{
      name = Some "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml", dest = "{{ plausible_home }}" }
    }
  , Item::{
      name = Some "Run plausible docker compose",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ plausible_home }}", state = "present" }
    }
  , Item::{ include_tasks = Some "backup.yml", when = Some "plausible_backup_enabled" }
]
