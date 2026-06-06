import { type TaskFile } from "../../../lib/ansible/play.ts";
import { isDefined } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

export default [
  // This task will install the flexpart simulation software (in a docker image)
  // and various helper scripts.
  {
    import_tasks: "flexpart_run.yml",
    tags: ["flexpart_only", "flexpart_run"],
    when: isDefined(V.flexpart_install_run),
  },
  // This task will install support for starting the flexpart simulations remotely
  // using a locked-down ssh account. The flexpart_ssh_users is a list ['alice',
  // 'bob'] which will be given remote access.
  {
    import_tasks: "flexpart_ssh.yml",
    tags: ["flexpart_only", "flexpart_ssh"],
    when: isDefined(V.flexpart_ssh_users),
  },
] satisfies TaskFile;
