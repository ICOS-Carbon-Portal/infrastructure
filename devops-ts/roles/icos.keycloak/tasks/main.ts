import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create keycloak directory",
    file: {
      path: tmpl`${V.kc_home}/conf`,
      state: "directory",
    },
  },
  {
    name: "Copy files",
    template: {
      src: "{{ item.src }}",
      dest: "{{ item.dest }}",
      lstrip_blocks: true,
    },
    loop: [
      {
        src: "docker-compose.yml",
        dest: tmpl`${V.kc_home}/docker-compose.yml`,
      },
      { src: "keycloak.conf", dest: tmpl`${V.kc_home}/conf/keycloak.conf` },
    ],
    register: "_config",
  },
  {
    name: "Build and start keycloak",
    docker_compose: {
      project_src: V.kc_home,
      restarted: "{{ _config.changed }}",
    },
  },
  {
    include_role: {
      name: "icos.nginxsite",
    },
    vars: {
      nginxsite_name: "keycloak",
      nginxsite_file: "keycloak-nginx.conf",
      nginxsite_domains: ["{{ kc_hostname }}"],
    },
  },
] satisfies TaskFile;
