import { matomo_backup_enable, matomo_domain, matomo_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Create home directory",
    file: {
      path: matomo_home,
      state: "directory",
    },
  },
  {
    include_role: {
      name: "icos.nginxsite",
    },
    vars: {
      nginxsite_name: "matomo",
      nginxsite_file: "matomo-nginx.conf",
      nginxsite_domains: [matomo_domain],
    },
  },
  {
    name: "Copy db.env",
    template: {
      src: "db.env",
      dest: matomo_home,
    },
  },
  {
    name: "Copy matomo.conf",
    template: {
      src: "matomo.conf",
      dest: matomo_home,
    },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: matomo_home,
    },
  },
  {
    name: "Run matomo docker compose",
    docker_compose: {
      project_src: matomo_home,
      state: "present",
    },
  },
  {
    include_tasks: "backup.yml",
    when: truthy(matomo_backup_enable),
  },
] satisfies TaskFile;
