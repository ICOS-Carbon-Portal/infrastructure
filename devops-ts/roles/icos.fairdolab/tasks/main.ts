import { fairdolab_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Create  directory",
    file: {
      path: fairdolab_home,
      state: "directory",
    },
  },
  {
    name: "Clone fairdolab",
    git: {
      repo: "https://github.com/kit-data-manager/FAIR-DO-Lab",
      dest: fairdolab_home,
      update: false,
    },
    diff: false,
  },
  {
    name: "Create docker-compose.yml",
    template: {
      dest: fairdolab_home,
      src: "docker-compose.yml",
    },
  },
  {
    name: "Build and start",
    docker_compose: {
      project_src: fairdolab_home,
      build: true,
    },
  },
] satisfies TaskFile;
