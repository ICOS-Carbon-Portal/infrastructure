import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOverVar } from "../../../lib/loop.ts";

export default [
  loopOverVar<{ content: string; dest: string }>(
    V.fail2ban_config_files,
    (item) => ({
      name: "Create fail2ban config files",
      copy: {
        dest: item.dest,
        content: item.content,
      },
      loop_control: {
        label: item.dest,
      },
      notify: "fail2ban reload",
    }),
  ),
] satisfies TaskFile;
