import { loopOver, raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create directories",
    file: { path: V.rdflog_home, state: "directory", mode: 0o700 },
  },
  {
    name: "Create rdflog initdb",
    file: { path: tmpl`${V.rdflog_home}/initdb`, state: "directory" },
  },
  {
    name: "Install postgres ssl key/certificate",
    copy: { dest: tmpl`${V.rdflog_home}/initdb`, src: V.item },
    loop: ["server.crt", "server.key"],
  },
  loopOver<{ src: string; dest?: string; mode?: string }>(
    [
      { src: "status.sql" },
      { src: "ctl.sql" },
      { src: "docker-compose.yml" },
      { src: "init.sql", dest: tmpl`${V.rdflog_home}/initdb` },
      { src: "init.sh", dest: tmpl`${V.rdflog_home}/initdb` },
      { src: "psql.sh", mode: "+x" },
    ],
    (item) => ({
      name: "Install templates",
      template: {
        dest: "{{ item.dest | default(rdflog_home) }}",
        src: item.src,
        mode: "{{ item.mode | default(omit) }}",
      },
    }),
  ),
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": { project_src: V.rdflog_home },
  },
  {
    name: "Test database connection (by loading ctl.sql)",
    shell:
      tmpl`${V.rdflog_home}/psql.sh ${V.rdflog_db_name} < ${V.rdflog_home}/ctl.sql`,
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
