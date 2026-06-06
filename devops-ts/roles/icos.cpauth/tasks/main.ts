import { type TaskFile } from "../../../lib/ansible/play.ts";
import { isDefined } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpauth_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpauth_deploy",
    when: isDefined(V.cpauth_jar_file),
  },
  { import_tasks: "backup.yml", tags: "cpauth_backup" },
] satisfies TaskFile;
