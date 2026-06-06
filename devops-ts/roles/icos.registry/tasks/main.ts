import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    import_tasks: "auth.yml",
    tags: "registry_auth",
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: tmpl`${V.registry_home}/`,
    },
  },
  // Not sure yet what this is for, generate it mostly to silence warning about
  // "No HTTP secret provided" when starting the registry service.
  {
    name: "Create http secret",
    shell:
      `openssl rand -hex 20 | awk '{ print "REGISTRY_HTTP_SECRET=" $1 }' > .env`,
    args: {
      chdir: V.registry_home,
      creates: ".env",
    },
  },
  {
    name: "Start Build and start containers",
    "community.docker.docker_compose_v2": {
      project_src: V.registry_home,
    },
  },
] satisfies TaskFile;
