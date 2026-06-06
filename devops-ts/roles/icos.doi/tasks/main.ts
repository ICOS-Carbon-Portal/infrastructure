import { type TaskFile } from "../../../lib/ansible/play.ts";
import { doi_jar_file } from "../../../lib/paramvars.ts";
import { isDefined } from "../../../lib/vars.ts";

export default [
  {
    import_tasks: "setup.yml",
    tags: "doi_setup",
  },
  {
    import_tasks: "deploy.yml",
    tags: "doi_deploy",
    when: isDefined(doi_jar_file),
  },
] satisfies TaskFile;
