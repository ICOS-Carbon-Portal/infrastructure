-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
    , template : Optional ({ src : Text, dest : Text })
    , docker_compose : Optional ({ project_src : Text, state : Text })
    , include_tasks : Optional Text
    , when : Optional Text
  }
    , default =
        { name = None Text
    , file = None ({ path : Text, state : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
    , template = None ({ src : Text, dest : Text })
    , docker_compose = None ({ project_src : Text, state : Text })
    , include_tasks = None Text
    , when = None Text
  }
    }

in  [
    Item::{
      name = Some "Create home directory",
      file = Some { path = "{{ matomo_home }}", state = "directory" }
    }
  , Item::{
      include_role = Some { name = "icos.nginxsite" },
      vars = Some {
        nginxsite_name = "matomo"
      , nginxsite_file = "matomo-nginx.conf"
      , nginxsite_domains = [ "{{ matomo_domain }}" ]
    }
    }
  , Item::{
      name = Some "Copy db.env",
      template = Some { src = "db.env", dest = "{{ matomo_home }}" }
    }
  , Item::{
      name = Some "Copy matomo.conf",
      template = Some { src = "matomo.conf", dest = "{{ matomo_home }}" }
    }
  , Item::{
      name = Some "Copy docker-compose.yml",
      template = Some { src = "docker-compose.yml", dest = "{{ matomo_home }}" }
    }
  , Item::{
      name = Some "Run matomo docker compose",
      docker_compose = Some { project_src = "{{ matomo_home }}", state = "present" }
    }
  , Item::{ include_tasks = Some "backup.yml", when = Some "matomo_backup_enable" }
]
