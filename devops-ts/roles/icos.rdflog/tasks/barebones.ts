import { rdflog_db_name, rdflog_db_port, rdflog_db_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  rdflog_db_pass,
  rdflog_postgres_version,
} from "../../../lib/globals.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "(Re-)install rdflog postgres container",
    "community.general.docker_container": {
      name: "rdflog",
      image: tmpl`postgres:${rdflog_postgres_version}`,
      state: "started",
      recreate: false,
      env: {
        POSTGRES_USER: rdflog_db_user,
        POSTGRES_PASSWORD: rdflog_db_pass,
        POSTGRES_DB: rdflog_db_name,
      },
      published_ports: [tmpl`127.0.0.1:${rdflog_db_port}:5432`],
      volumes: ["/docker/rdflog/volumes/data:/var/lib/postgresql/data"],
      restart_policy: "always",
    },
  },
  {
    name: "Wait for rdflog db to become available",
    wait_for: {
      host: "127.0.0.1",
      port: rdflog_db_port,
      delay: 5,
      timeout: 60,
    },
  },
] satisfies TaskFile;
