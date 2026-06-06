import { type TaskFile } from "../../../lib/ansible/play.ts";
import { cpmeta_backup_enable } from "../../../lib/globals.ts";
import { cpmeta_jar_file } from "../../../lib/paramvars.ts";
import { isDefined, truthy } from "../../../lib/vars.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpmeta_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpmeta_deploy",
    when: isDefined(cpmeta_jar_file),
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
    when: truthy(cpmeta_backup_enable).default(false),
  },
] satisfies TaskFile;
