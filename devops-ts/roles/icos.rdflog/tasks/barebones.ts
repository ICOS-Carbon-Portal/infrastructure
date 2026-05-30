import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "(Re-)install rdflog postgres container",
    "community.general.docker_container": {
      name: "rdflog",
      image: tmpl`postgres:${V.rdflog_postgres_version}`,
      state: "started",
      recreate: false,
      env: {
        POSTGRES_USER: V.rdflog_db_user,
        POSTGRES_PASSWORD: V.rdflog_db_pass,
        POSTGRES_DB: V.rdflog_db_name,
      },
      published_ports: [tmpl`127.0.0.1:${V.rdflog_db_port}:5432`],
      volumes: ["/docker/rdflog/volumes/data:/var/lib/postgresql/data"],
      restart_policy: "always",
    },
  },
  {
    name: "Wait for rdflog db to become available",
    wait_for: {
      host: "127.0.0.1",
      port: V.rdflog_db_port,
      delay: 5,
      timeout: 60,
    },
  },
] satisfies TaskFile;
