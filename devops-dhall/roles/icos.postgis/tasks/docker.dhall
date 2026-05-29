-- Auto-generated from ../../../../devops/roles/icos.postgis/tasks/docker.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Ensure the postgis PostgreSQL container is present",
      `community.general.docker_container` = Some {
        name = "{{ postgis_container_name }}",
        image = "postgres:{{ postgis_postgres_version }}",
        state = "started",
        recreate = False,
        shm_size = Some "500M",
        env = {
          POSTGRES_USER = "{{ postgis_db_user }}",
          POSTGRES_PASSWORD = "{{ postgis_db_pass }}",
          POSTGRES_DB = "{{ postgis_db_name }}"
      },
        published_ports = [ "127.0.0.1:{{ postgis_db_port }}:5432" ],
        volumes = [ "{{ postgis_container_name }}:/var/lib/postgresql/data" ],
        restart_policy = "always"
    }
    }
  , Task::{
      name = Some "Wait for postgis PostgreSQL to become available",
      wait_for = Some { host = "127.0.0.1", port = "{{ postgis_db_port }}", delay = 5, timeout = 60 }
    }
  , Task::{
      name = Some "Install postgis using apt-get",
      `community.docker.docker_container_exec` = Some {
        container = "{{ postgis_container_name }}",
        command = "/bin/bash -c \"apt-get update && apt-get -y install {{ postgis_package }}\"",
        chdir = "/root"
    }
    }
  , Task::{
      name = Some "Install psycopg2 for Ansible to be able to create postgresql dbs and users",
      pip = Some (Task.Poly_pip.Str "name=psycopg2-binary"),
      become = Some (Task.Poly_become.Bool True)
    }
  , Task::{
      name = Some "Create postgis databases",
      postgresql_db = Some {
        name = "{{ item }}",
        login_user = "{{ postgis_db_user }}",
        login_password = "{{ postgis_db_pass }}",
        login_host = "127.0.0.1",
        login_port = "{{ postgis_db_port }}",
        maintenance_db = "{{ postgis_db_name }}"
    },
      loop = Some (Task.Poly_loop.Str "{{ postgis_dbs }}")
    }
  , Task::{
      name = Some "Create users in each postgis database",
      include_tasks = Some (Task.Poly_include_tasks.Str "users.yml"),
      loop = Some (Task.Poly_loop.Str "{{ postgis_dbs }}"),
      loop_control = Some { loop_var = Some "db_name", label = None Text }
    }
]
