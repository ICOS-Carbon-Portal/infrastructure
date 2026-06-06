import { nexus_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Create nexus home directory",
    file: {
      path: nexus_home,
      state: "directory",
    },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: nexus_home,
    },
  },
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": {
      project_src: nexus_home,
    },
  },
] satisfies TaskFile;
