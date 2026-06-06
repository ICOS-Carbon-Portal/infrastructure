import { type TaskFile } from "../../../lib/ansible/play.ts";
import { isDefined, truthy } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpmeta_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpmeta_deploy",
    when: isDefined(V.cpmeta_jar_file),
  },
  {
    import_tasks: "restart.yml",
    tags: "cpmeta_restart",
    vars: {
      _restart_needed: true,
    },
  },
  {
    import_tasks: "backup.yml",
    tags: "cpmeta_backup",
    when: truthy(V.cpmeta_backup_enable).default(false),
  },
] satisfies TaskFile;
