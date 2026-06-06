import { type Playbook } from "../lib/ansible/play.ts";
import { V } from "../lib/vars.ts";

export default [
  {
    hosts: "core_host",
    connection: "local",
    tasks: [
      {
        name: "Make sure borg is installed",
        tags: ["setup"],
        import_role: {
          name: "icos.borg",
        },
      },
      {
        name: "Restore rdflog backup",
        tags: ["rdflog"],
        import_role: {
          name: "icos.postgresql",
          tasks_from: "restore.yml",
        },
        vars: {
          postgresql_backup_host: V.corebackup_host,
          postgresql_backup_location: V.rdflog_backup_location,
          container_name: V.rdflog_container_name,
          postgresql_user: V.rdflog_user,
          postgresql_container_name: "rdflog",
        },
      },
      {
        name: "Restore postgis backup",
        tags: ["postgis"],
        import_role: {
          name: "icos.postgresql",
          tasks_from: "restore.yml",
        },
        vars: {
          postgresql_backup_host: V.corebackup_host,
          postgresql_backup_location: V.postgis_backup_location,
          container_name: V.postgis_container_name,
          postgresql_user: V.postgis_user,
          postgresql_container_name: "postgis",
        },
      },
      {
        name: "Restore restheart backup",
        tags: ["restheart"],
        import_role: {
          name: "icos.restheart",
          tasks_from: "restore.yml",
        },
        vars: {
          restheart_backup_host: V.corebackup_host,
        },
      },
    ],
  },
] satisfies Playbook;
