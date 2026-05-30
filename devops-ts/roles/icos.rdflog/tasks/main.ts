import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create directories",
    file: { path: "{{ rdflog_home }}", state: "directory", mode: 0o700 },
  },
  {
    name: "Create rdflog initdb",
    file: { path: "{{ rdflog_home }}/initdb", state: "directory" },
  },
  {
    name: "Install postgres ssl key/certificate",
    copy: { dest: "{{ rdflog_home }}/initdb", src: "{{ item }}" },
    loop: ["server.crt", "server.key"],
  },
  {
    name: "Install templates",
    template: {
      dest: "{{ item.dest | default(rdflog_home) }}",
      src: "{{ item.src }}",
      mode: "{{ item.mode | default(omit) }}",
    },
    loop: [
      { src: "status.sql" },
      { src: "ctl.sql" },
      { src: "docker-compose.yml" },
      { src: "init.sql", dest: "{{ rdflog_home }}/initdb" },
      { src: "init.sh", dest: "{{ rdflog_home }}/initdb" },
      { src: "psql.sh", mode: "+x" },
    ],
  },
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": { project_src: "{{ rdflog_home }}" },
  },
  {
    name: "Test database connection (by loading ctl.sql)",
    shell:
      "{{ rdflog_home }}/psql.sh {{ rdflog_db_name }} < {{ rdflog_home }}/ctl.sql",
    register: "r",
    changed_when: false,
    retries: 10,
    delay: 5,
    until: "r.rc == 0",
  },
  {
    import_tasks: "restore.yml",
    tags: "rdflog_restore",
    when: raw("rdflog_restore_file is defined"),
  },
] satisfies TaskFile;
