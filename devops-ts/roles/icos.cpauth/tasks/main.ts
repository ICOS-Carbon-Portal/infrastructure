import { type TaskFile } from "../../../lib/ansible/play.ts";
import { cpauth_jar_file } from "../../../lib/paramvars.ts";
import { isDefined } from "../../../lib/vars.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpauth_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpauth_deploy",
    when: isDefined(cpauth_jar_file),
  },
  { import_tasks: "backup.yml", tags: "cpauth_backup" },
] satisfies TaskFile;
