import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create nexus home directory",
    file: {
      path: V.nexus_home,
      state: "directory",
    },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: V.nexus_home,
    },
  },
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": {
      project_src: V.nexus_home,
    },
  },
] satisfies TaskFile;
