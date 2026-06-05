import { isDefined, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpdata_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpdata_deploy",
    when: isDefined(V.cpdata_jar_file),
  },
] satisfies TaskFile;
