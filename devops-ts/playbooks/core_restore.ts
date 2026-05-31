import { expr, type Playbook, tmpl } from "../lib/ansible.ts";

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
          postgresql_backup_host: expr("corebackup_host"),
          postgresql_backup_location: expr("rdflog_backup_location"),
          container_name: expr("rdflog_container_name"),
          postgresql_user: expr("rdflog_user"),
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
          postgresql_backup_host: expr("corebackup_host"),
          postgresql_backup_location: expr("postgis_backup_location"),
          container_name: expr("postgis_container_name"),
          postgresql_user: expr("postgis_user"),
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
          restheart_backup_host: expr("corebackup_host"),
        },
      },
    ],
  },
] satisfies Playbook;
