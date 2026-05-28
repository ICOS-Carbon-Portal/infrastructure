-- Auto-generated from main.yml

let Item =
    { Type =
        { import_role : Optional ({ name : Text })
    , name : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop : Optional (List Text)
    , copy : Optional ({ src : Text, dest : Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text })
    , iptables_raw : Optional ({ name : Text, rules : Text })
  }
    , default =
        { import_role = None ({ name : Text })
    , name = None Text
    , file = None ({ path : Text, state : Text })
    , template = None ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop = None (List Text)
    , copy = None ({ src : Text, dest : Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text })
    , iptables_raw = None ({ name : Text, rules : Text })
  }
    }

in  [
    Item::{ import_role = Some { name = "icos.certbot2" } }
  , Item::{
      name = Some "Create dataold home directory",
      file = Some { path = "{{ dataold_home }}", state = "directory" }
    }
  , Item::{
      name = Some "Copy templates",
      template = Some { src = "{{ item }}", dest = "{{ dataold_home }}", lstrip_blocks = True },
      loop = Some [ "docker-compose.yml", "dataold.conf" ]
    }
  , Item::{
      name = Some "Copy files",
      loop = Some [ "openssl.cnf" ],
      copy = Some { src = "{{ item }}", dest = "{{ dataold_home }}" }
    }
  , Item::{
      name = Some "Start dataold",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ dataold_home }}" }
    }
  , Item::{
      name = Some "Open firewall for port {{ dataold_ext_port }}",
      iptables_raw = Some {
        name = "allow_{{ dataold_ext_port }}"
      , rules = "-A INPUT -p tcp --dport {{ dataold_ext_port }} -j ACCEPT -m comment --comment 'dataold'"
    }
    }
]
