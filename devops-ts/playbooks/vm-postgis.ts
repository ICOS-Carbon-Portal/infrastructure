// Create users for the cplog database:
//   icos play postgis cplog
//
// Redeploy backup script and bbclient
//   icos play postgis backup

import { expr, type Playbook, role, V } from "../lib/ansible.ts";

export default [
  {
    hosts: "postgis_server",
    roles: [
      role("icos.lxd_vm", {
        name: "Create the postgis VM",
        lxd_vm_name: "postgis",
        lxd_vm_root_size: "50GB",
        lxd_vm_config: {
          "security.nesting": "true",
          "limits.cpu": "4",
          "limits.memory": "10GB",
        },
      }).tags("vm"),
    ],
  },
  {
    hosts: "postgis_host",
    roles: [
      role("icos.lxd_guest").tags("guest"),
      role("icos.postgis").tags("postgis"),
    ],
    tasks: [
      {
        include_role: "name=icos.postgresql",
        tags: "postgresql",
        vars: {
          postgresql_postgis_enable: true,
          postgresql_postgres_password: V.postgis_admin_pass,
          postgresql_listen_addresses: "'*'",
          postgresql_pg_stat_enable: true,
        },
      },
      {
        name: "Install backup for postgresql",
        tags: "backup",
        include_role: {
          name: "icos.postgresql",
          tasks_from: "backup",
        },
        vars: {
          postgresql_backup_script: "backup-dumpall-bbclient",
          postgis_bbclient_name: "postgis",
        },
      },
      {
        name: "Allow postgres user to connect from same subnet",
        tags: "hba",
        postgresql_pg_hba: {
          dest: expr("postgresql_hba_file"),
          users: "postgres",
          source: "samenet",
          method: "md5",
          contype: "hostssl",
        },
      },
      // Switch to postgres so we use socket authentication.
      {
        become: true,
        become_user: "postgres",
        tags: "cplog",
        block: [
          {
            name: "Create postgres cplog users",
            postgresql_user: {
              db: "cplog",
              name: expr("item.username"),
              password: expr("item.password"),
            },
            loop: expr("postgis_cplog_users"),
          },
          {
            name: "Allow users to connect from same subnet",
            postgresql_pg_hba: {
              dest: expr("postgresql_hba_file"),
              users: expr("item.username"),
              source: "samenet",
              method: "md5",
              contype: "hostssl",
            },
            loop: expr("postgis_cplog_users"),
          },
          {
            name: "Add the pg_stat_statements extension",
            "community.postgresql.postgresql_ext": {
              name: "pg_stat_statements",
              db: "cplog",
              schema: "public",
            },
          },
        ],
      },
    ],
  },
] satisfies Playbook;
