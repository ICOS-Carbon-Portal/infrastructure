import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Ensure the postgis PostgreSQL container is present",
    "community.general.docker_container": {
      name: V.postgis_container_name,
      image: tmpl`postgres:${V.postgis_postgres_version}`,
      state: "started",
      recreate: false,
      shm_size: "500M",
      env: {
        POSTGRES_USER: V.postgis_db_user,
        POSTGRES_PASSWORD: V.postgis_db_pass,
        POSTGRES_DB: V.postgis_db_name,
      },
      published_ports: [tmpl`127.0.0.1:${V.postgis_db_port}:5432`],
      volumes: [tmpl`${V.postgis_container_name}:/var/lib/postgresql/data`],
      restart_policy: "always",
    },
  },
  {
    name: "Wait for postgis PostgreSQL to become available",
    wait_for: {
      host: "127.0.0.1",
      port: V.postgis_db_port,
      delay: 5,
      timeout: 60,
    },
  },
  {
    name: "Install postgis using apt-get",
    "community.docker.docker_container_exec": {
      container: V.postgis_container_name,
      command:
        tmpl`/bin/bash -c "apt-get update && apt-get -y install ${V.postgis_package}"`,
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
      name: V.item,
      login_user: V.postgis_db_user,
      login_password: V.postgis_db_pass,
      login_host: "127.0.0.1",
      login_port: V.postgis_db_port,
      maintenance_db: V.postgis_db_name,
    },
    loop: V.postgis_dbs,
  },
  {
    name: "Create users in each postgis database",
    include_tasks: "users.yml",
    loop: V.postgis_dbs,
    loop_control: { loop_var: "db_name" },
  },
] satisfies TaskFile;
