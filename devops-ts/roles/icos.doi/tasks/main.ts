import { type TaskFile } from "../../../lib/ansible/play.ts";
import { isDefined } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

export default [
  {
    import_tasks: "setup.yml",
    tags: "doi_setup",
  },
  {
    import_tasks: "deploy.yml",
    tags: "doi_deploy",
    when: isDefined(V.doi_jar_file),
  },
] satisfies TaskFile;
