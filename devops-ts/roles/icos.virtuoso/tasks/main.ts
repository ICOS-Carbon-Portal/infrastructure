import { virtuoso_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { or } from "../../../lib/vars.ts";

const _virtuoso_ini = register("_virtuoso_ini");
const _virtuoso_compose = register("_virtuoso_compose");

export default [
  {
    name: "Create volume directories",
    file: {
      path: item,
      state: "directory",
    },
    loop: [
      tmpl`${virtuoso_home}/volumes/virtuoso.db`,
    ],
  },
  {
    name: "Copy virtuoso.ini",
    template: {
      src: "virtuoso.ini",
      dest: tmpl`${virtuoso_home}/volumes/virtuoso.db/virtuoso.ini`,
    },
    register: _virtuoso_ini,
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: virtuoso_home,
    },
    register: _virtuoso_compose,
  },
  {
    name: "Start Virtuoso",
    "community.docker.docker_compose_v2": {
      project_src: virtuoso_home,
      state: "present",
      pull: "always",
    },
  },
  {
    name: "Restart Virtuoso if config changed",
    "community.docker.docker_compose_v2": {
      project_src: virtuoso_home,
      state: "restarted",
    },
    when: or(_virtuoso_ini.changed, _virtuoso_compose.changed),
  },
] satisfies TaskFile;
