-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ path : Text, state : Optional Text, owner : Optional Natural, recurse : Optional Bool })
    , loop : Optional (List Text)
    , changed_when : Optional Bool
    , template : Optional ({ src : Text, dest : Text })
    , copy : Optional ({ content : Text, dest : Text })
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, pull : Text })
    , import_tasks : Optional Text
    , tags : Optional Text
    , uri : Optional ({ url : Text })
    , retries : Optional Natural
    , loop_control : Optional ({ label : Text })
  }
    , default =
        { name = None Text
    , file = None ({ path : Text, state : Optional Text, owner : Optional Natural, recurse : Optional Bool })
    , loop = None (List Text)
    , changed_when = None Bool
    , template = None ({ src : Text, dest : Text })
    , copy = None ({ content : Text, dest : Text })
    , `community.docker.docker_compose_v2` = None ({ project_src : Text, pull : Text })
    , import_tasks = None Text
    , tags = None Text
    , uri = None ({ url : Text })
    , retries = None Natural
    , loop_control = None ({ label : Text })
  }
    }

in  [
    Item::{
      name = Some "Create victoriametrics directories",
      file = Some {
        path = "{{ vm_home }}/{{ item }}"
      , state = Some "directory"
      , owner = None Natural
      , recurse = None Bool
    },
      loop = Some [ "victoriametrics/prometheus", "grafana/provisioning" ]
    }
  , Item::{
      name = Some "Change owner of grafana directories",
      file = Some {
        path = "{{ vm_home }}/grafana"
      , state = None Text
      , owner = Some 472
      , recurse = Some True
    },
      changed_when = Some False
    }
  , Item::{
      name = Some "Copy files",
      loop = Some [
        { src = Some "docker-compose.yml", dest = None Text, name = None Text, port = None Text }
      , { src = Some "grafana.ini", dest = Some "grafana", name = None Text, port = None Text }
    ],
      template = Some { src = "{{ item.src }}", dest = "{{ vm_home }}/{{ item.dest | default('') }}" }
    }
  , Item::{
      name = Some "Create victoriametrics scrape config",
      copy = Some {
        content = "{{ vm_scrape_conf }}"
      , dest = "{{ vm_home }}/victoriametrics/prometheus/prometheus.yml"
    }
    }
  , Item::{
      name = Some "Build and start",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ vm_home }}"
      , pull = "{{ 'always' if vm_upgrade else omit }}"
    }
    }
  , Item::{ import_tasks = Some "grafana_datasource.yml", tags = Some "grafana_datasource" }
  , Item::{
      name = Some "Check that services responds on local ports",
      loop = Some [
        {
          src = None Text,
          dest = None Text,
          name = Some "victoriametrics",
          port = Some "{{ vm_vm_port }}"
        }
      , {
          src = None Text,
          dest = None Text,
          name = Some "grafana",
          port = Some "{{ vm_graf_port }}"
        }
    ],
      uri = Some { url = "http://localhost:{{ item.port }}" },
      retries = Some 10,
      loop_control = Some { label = "{{ item.name }}" }
    }
  , Item::{ import_tasks = Some "just.yml", tags = Some "victoriametrics_just" }
]
