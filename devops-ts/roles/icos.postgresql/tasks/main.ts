import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

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
