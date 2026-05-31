import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create fail2ban config files",
    copy: {
      dest: tmpl("{{ item.dest }}"),
      content: tmpl("{{ item.content }}"),
    },
    loop: V.fail2ban_config_files,
    loop_control: {
      label: tmpl("{{ item.dest }}"),
    },
    notify: "fail2ban reload",
  },
] satisfies TaskFile;
