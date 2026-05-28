-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop : Optional (List ({ src : Text, dest : Text }))
    , register : Optional Text
    , docker_compose : Optional ({ project_src : Text, restarted : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
  }
    , default =
        { name = None Text
    , file = None ({ path : Text, state : Text })
    , template = None ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop = None (List ({ src : Text, dest : Text }))
    , register = None Text
    , docker_compose = None ({ project_src : Text, restarted : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ nginxsite_name : Text, nginxsite_file : Text, nginxsite_domains : List Text })
  }
    }

in  [
    Item::{
      name = Some "Create keycloak directory",
      file = Some { path = "{{ kc_home }}/conf", state = "directory" }
    }
  , Item::{
      name = Some "Copy files",
      template = Some { src = "{{ item.src }}", dest = "{{ item.dest }}", lstrip_blocks = True },
      loop = Some [
        { src = "docker-compose.yml", dest = "{{ kc_home }}/docker-compose.yml" }
      , { src = "keycloak.conf", dest = "{{ kc_home }}/conf/keycloak.conf" }
    ],
      register = Some "_config"
    }
  , Item::{
      name = Some "Build and start keycloak",
      docker_compose = Some { project_src = "{{ kc_home }}", restarted = "{{ _config.changed }}" }
    }
  , Item::{
      include_role = Some { name = "icos.nginxsite" },
      vars = Some {
        nginxsite_name = "keycloak"
      , nginxsite_file = "keycloak-nginx.conf"
      , nginxsite_domains = [ "{{ kc_hostname }}" ]
    }
    }
]
