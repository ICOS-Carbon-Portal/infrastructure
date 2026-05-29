-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_role = Some { name = "icos.certbot2" } }
  , Task::{
      name = Some "Create dataold home directory",
      file = Some {
        path = Some "{{ dataold_home }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Copy templates",
      template = Some {
        src = "{{ item }}"
      , dest = "{{ dataold_home }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = Some True
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      loop = Some [ "docker-compose.yml", "dataold.conf" ]
    }
  , Task::{
      name = Some "Copy files",
      copy = Some {
        src = Some "{{ item }}"
      , dest = "{{ dataold_home }}"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "openssl.cnf" ]
    }
  , Task::{
      name = Some "Start dataold",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ dataold_home }}"
      , state = None Text
      , pull = None Text
      , services = None (List Text)
      , build = None Text
    }
    }
  , Task::{
      name = Some "Open firewall for port {{ dataold_ext_port }}",
      iptables_raw = Some {
        name = "allow_{{ dataold_ext_port }}"
      , rules = Some "-A INPUT -p tcp --dport {{ dataold_ext_port }} -j ACCEPT -m comment --comment 'dataold'"
      , weight = None Natural
      , table = None Text
      , state = None Text
    }
    }
]
