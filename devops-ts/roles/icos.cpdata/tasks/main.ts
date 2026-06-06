import { type TaskFile } from "../../../lib/ansible/play.ts";
import { cpdata_jar_file } from "../../../lib/paramvars.ts";
import { isDefined } from "../../../lib/vars.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpdata_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpdata_deploy",
    when: isDefined(cpdata_jar_file),
  },
] satisfies TaskFile;
