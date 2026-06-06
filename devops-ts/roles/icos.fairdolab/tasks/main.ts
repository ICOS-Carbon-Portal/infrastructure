import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create  directory",
    file: {
      path: V.fairdolab_home,
      state: "directory",
    },
  },
  {
    name: "Clone fairdolab",
    git: {
      repo: "https://github.com/kit-data-manager/FAIR-DO-Lab",
      dest: V.fairdolab_home,
      update: false,
    },
    diff: false,
  },
  {
    name: "Create docker-compose.yml",
    template: {
      dest: V.fairdolab_home,
      src: "docker-compose.yml",
    },
  },
  {
    name: "Build and start",
    docker_compose: {
      project_src: V.fairdolab_home,
      build: true,
    },
  },
] satisfies TaskFile;
