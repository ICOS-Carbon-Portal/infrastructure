import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create fail2ban config files",
    copy: {
      dest: expr("item.dest"),
      content: expr("item.content"),
    },
    loop: V.fail2ban_config_files,
    loop_control: {
      label: expr("item.dest"),
    },
    notify: "fail2ban reload",
  },
] satisfies TaskFile;
