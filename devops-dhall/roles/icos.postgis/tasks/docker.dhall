-- Auto-generated from docker.yml

let Entry =
    { Type =
        { name : Text
    , `community.general.docker_container` : Optional ({ name : Text, image : Text, state : Text, recreate : Bool, shm_size : Text, env : { POSTGRES_USER : Text, POSTGRES_PASSWORD : Text, POSTGRES_DB : Text }, published_ports : List Text, volumes : List Text, restart_policy : Text })
    , wait_for : Optional ({ host : Text, port : Text, delay : Natural, timeout : Natural })
    , `community.docker.docker_container_exec` : Optional ({ container : Text, command : Text, chdir : Text })
    , pip : Optional Text
    , become : Optional Bool
    , postgresql_db : Optional ({ name : Text, login_user : Text, login_password : Text, login_host : Text, login_port : Text, maintenance_db : Text })
    , loop : Optional Text
    , include_tasks : Optional Text
    , loop_control : Optional ({ loop_var : Text })
  }
    , default =
        { `community.general.docker_container` = None ({ name : Text, image : Text, state : Text, recreate : Bool, shm_size : Text, env : { POSTGRES_USER : Text, POSTGRES_PASSWORD : Text, POSTGRES_DB : Text }, published_ports : List Text, volumes : List Text, restart_policy : Text })
    , wait_for = None ({ host : Text, port : Text, delay : Natural, timeout : Natural })
    , `community.docker.docker_container_exec` = None ({ container : Text, command : Text, chdir : Text })
    , pip = None Text
    , become = None Bool
    , postgresql_db = None ({ name : Text, login_user : Text, login_password : Text, login_host : Text, login_port : Text, maintenance_db : Text })
    , loop = None Text
    , include_tasks = None Text
    , loop_control = None ({ loop_var : Text })
  }
    }

in  [
    Entry::{
      name = "Ensure the postgis PostgreSQL container is present",
      `community.general.docker_container` = Some {
        name = "{{ postgis_container_name }}"
      , image = "postgres:{{ postgis_postgres_version }}"
      , state = "started"
      , recreate = False
      , shm_size = "500M"
      , env = {
          POSTGRES_USER = "{{ postgis_db_user }}"
        , POSTGRES_PASSWORD = "{{ postgis_db_pass }}"
        , POSTGRES_DB = "{{ postgis_db_name }}"
      }
      , published_ports = [ "127.0.0.1:{{ postgis_db_port }}:5432" ]
      , volumes = [ "{{ postgis_container_name }}:/var/lib/postgresql/data" ]
      , restart_policy = "always"
    }
    }
  , Entry::{
      name = "Wait for postgis PostgreSQL to become available",
      wait_for = Some {
        host = "127.0.0.1"
      , port = "{{ postgis_db_port }}"
      , delay = 5
      , timeout = 60
    }
    }
  , Entry::{
      name = "Install postgis using apt-get",
      `community.docker.docker_container_exec` = Some {
        container = "{{ postgis_container_name }}"
      , command = "/bin/bash -c \"apt-get update && apt-get -y install {{ postgis_package }}\""
      , chdir = "/root"
    }
    }
  , Entry::{
      name = "Install psycopg2 for Ansible to be able to create postgresql dbs and users",
      pip = Some "name=psycopg2-binary",
      become = Some True
    }
  , Entry::{
      name = "Create postgis databases",
      postgresql_db = Some {
        name = "{{ item }}"
      , login_user = "{{ postgis_db_user }}"
      , login_password = "{{ postgis_db_pass }}"
      , login_host = "127.0.0.1"
      , login_port = "{{ postgis_db_port }}"
      , maintenance_db = "{{ postgis_db_name }}"
    },
      loop = Some "{{ postgis_dbs }}"
    }
  , Entry::{
      name = "Create users in each postgis database",
      loop = Some "{{ postgis_dbs }}",
      include_tasks = Some "users.yml",
      loop_control = Some { loop_var = "db_name" }
    }
]
