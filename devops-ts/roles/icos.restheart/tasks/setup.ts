import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create volume directories",
    file: {
      path: V.item,
      state: "directory",
    },
    loop: [tmpl`${V.restheart_home}/volumes/mongo.db`],
  },
  {
    name: "Copy restheart.yml",
    template: {
      src: "../templates/restheart.yml",
      dest: V.restheart_home,
    },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: V.restheart_home,
    },
  },
  {
    name: "Build and start the images",
    "community.docker.docker_compose_v2": {
      project_src: V.restheart_home,
      build: true,
    },
  },
  {
    name: "Install restore script",
    tags: "restheart_restore_script",
    template: {
      src: "restore_restheart_db.py",
      dest: "/usr/local/bin",
      mode: "+x",
    },
  },
] satisfies TaskFile;
