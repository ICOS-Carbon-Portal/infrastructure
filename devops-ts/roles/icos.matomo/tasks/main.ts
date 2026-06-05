import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create home directory",
    file: {
      path: V.matomo_home,
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
      nginxsite_domains: [V.matomo_domain],
    },
  },
  {
    name: "Copy db.env",
    template: {
      src: "db.env",
      dest: V.matomo_home,
    },
  },
  {
    name: "Copy matomo.conf",
    template: {
      src: "matomo.conf",
      dest: V.matomo_home,
    },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: V.matomo_home,
    },
  },
  {
    name: "Run matomo docker compose",
    docker_compose: {
      project_src: V.matomo_home,
      state: "present",
    },
  },
  {
    include_tasks: "backup.yml",
    when: truthy(V.matomo_backup_enable),
  },
] satisfies TaskFile;
