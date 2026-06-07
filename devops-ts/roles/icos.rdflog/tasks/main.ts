import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item, omit } from "../../../lib/builtins.ts";
import { loopOver } from "../../../lib/loop.ts";
import { rdflog_restore_file } from "../../../lib/paramvars.ts";
import { type Tmpl, tmpl } from "../../../lib/template.ts";
import { isDefined } from "../../../lib/vars.ts";

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
    copy: { dest: tmpl`${V.rdflog_home}/initdb`, src: item },
    loop: ["server.crt", "server.key"],
  },
  loopOver<{ src: Tmpl; dest?: Tmpl; mode?: Tmpl }>(
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
        dest: item.dest.default(V.rdflog_home),
        src: item.src,
        mode: item.mode.default(omit),
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
    when: isDefined(rdflog_restore_file),
  },
] satisfies TaskFile;
