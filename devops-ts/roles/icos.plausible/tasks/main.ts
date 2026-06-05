import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create home directory",
    file: {
      path: V.plausible_home,
      state: "directory",
    },
  },
  {
    include_role: { name: "icos.nginxsite" },
    vars: {
      nginxsite_name: "plausible",
      nginxsite_file: "plausible-nginx.conf",
      nginxsite_domains: [V.plausible_domain],
    },
  },
  {
    name: "Copy clickhouse-config.xml",
    copy: {
      src: "clickhouse-config.xml",
      dest: tmpl`${V.plausible_home}/clickhouse/`,
    },
  },
  {
    name: "Copy clickhouse-user-config.xml",
    copy: {
      src: "clickhouse-user-config.xml",
      dest: tmpl`${V.plausible_home}/clickhouse/`,
    },
  },
  {
    name: "Copy plausible-conf.env",
    template: {
      src: "plausible-conf.env",
      dest: V.plausible_home,
    },
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml",
      dest: V.plausible_home,
    },
  },
  {
    name: "Run plausible docker compose",
    "community.docker.docker_compose_v2": {
      project_src: V.plausible_home,
      state: "present",
    },
  },
  {
    include_tasks: "backup.yml",
    when: truthy(V.plausible_backup_enabled),
  },
] satisfies TaskFile;
