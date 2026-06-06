import {
  postgis_db_name,
  postgis_db_pass,
  postgis_db_user,
  postgis_package,
  postgis_postgres_version,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import {
  postgis_container_name,
  postgis_db_port,
  postgis_dbs,
} from "../../../lib/globals.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Ensure the postgis PostgreSQL container is present",
    "community.general.docker_container": {
      name: postgis_container_name,
      image: tmpl`postgres:${postgis_postgres_version}`,
      state: "started",
      recreate: false,
      shm_size: "500M",
      env: {
        POSTGRES_USER: postgis_db_user,
        POSTGRES_PASSWORD: postgis_db_pass,
        POSTGRES_DB: postgis_db_name,
      },
      published_ports: [tmpl`127.0.0.1:${postgis_db_port}:5432`],
      volumes: [tmpl`${postgis_container_name}:/var/lib/postgresql/data`],
      restart_policy: "always",
    },
  },
  {
    name: "Wait for postgis PostgreSQL to become available",
    wait_for: {
      host: "127.0.0.1",
      port: postgis_db_port,
      delay: 5,
      timeout: 60,
    },
  },
  {
    name: "Install postgis using apt-get",
    "community.docker.docker_container_exec": {
      container: postgis_container_name,
      command:
        tmpl`/bin/bash -c "apt-get update && apt-get -y install ${postgis_package}"`,
      chdir: "/root",
    },
  },
  {
    name:
      "Install psycopg2 for Ansible to be able to create postgresql dbs and users",
    pip: "name=psycopg2-binary",
    become: true,
  },
  {
    name: "Create postgis databases",
    postgresql_db: {
      name: item,
      login_user: postgis_db_user,
      login_password: postgis_db_pass,
      login_host: "127.0.0.1",
      login_port: postgis_db_port,
      maintenance_db: postgis_db_name,
    },
    loop: postgis_dbs,
  },
  {
    name: "Create users in each postgis database",
    include_tasks: "users.yml",
    loop: postgis_dbs,
    loop_control: { loop_var: "db_name" },
  },
] satisfies TaskFile;
