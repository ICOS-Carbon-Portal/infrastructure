import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    import_tasks: "install.yml",
    tags: "postgresql_install",
  },
  {
    import_tasks: "config.yml",
    tags: "postgresql_config",
  },
  {
    import_tasks: "pg_stat.yml",
    tags: "postgresql_pg_stat",
    when: truthy(V.postgresql_pg_stat_enable),
  },
  {
    import_tasks: "util.yml",
    tags: "postgresql_util",
  },
] satisfies TaskFile;
