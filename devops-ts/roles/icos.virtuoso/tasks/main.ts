import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create volume directories",
    file: {
      path: V.item,
      state: "directory",
    },
    loop: [
      tmpl`${V.virtuoso_home}/volumes/virtuoso.db`,
    ],
  },
  {
    name: "Copy virtuoso.ini",
    template: {
      src: "virtuoso.ini",
      dest: tmpl`${V.virtuoso_home}/volumes/virtuoso.db/virtuoso.ini`,
    },
    register: "_virtuoso_ini",
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: V.virtuoso_home,
    },
    register: "_virtuoso_compose",
  },
  {
    name: "Start Virtuoso",
    "community.docker.docker_compose_v2": {
      project_src: V.virtuoso_home,
      state: "present",
      pull: "always",
    },
  },
  {
    name: "Restart Virtuoso if config changed",
    "community.docker.docker_compose_v2": {
      project_src: V.virtuoso_home,
      state: "restarted",
    },
    when: raw("_virtuoso_ini.changed or _virtuoso_compose.changed"),
  },
] satisfies TaskFile;
