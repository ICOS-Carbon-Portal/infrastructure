import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOver } from "../../../lib/loop.ts";
import { kc_hostname } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { type Tmpl, tmpl } from "../../../lib/template.ts";

const _config = register("_config");

export default [
  {
    name: "Create keycloak directory",
    file: {
      path: tmpl`${V.kc_home}/conf`,
      state: "directory",
    },
  },
  loopOver<{ src: Tmpl; dest: Tmpl }>(
    [
      {
        src: "docker-compose.yml",
        dest: tmpl`${V.kc_home}/docker-compose.yml`,
      },
      { src: "keycloak.conf", dest: tmpl`${V.kc_home}/conf/keycloak.conf` },
    ],
    (item) => ({
      name: "Copy files",
      template: {
        src: item.src,
        dest: item.dest,
        lstrip_blocks: true,
      },
      register: _config,
    }),
  ),
  {
    name: "Build and start keycloak",
    docker_compose: {
      project_src: V.kc_home,
      restarted: _config.changed.ref,
    },
  },
  {
    include_role: {
      name: "icos.nginxsite",
    },
    vars: {
      nginxsite_name: "keycloak",
      nginxsite_file: "keycloak-nginx.conf",
      nginxsite_domains: [kc_hostname],
    },
  },
] satisfies TaskFile;
