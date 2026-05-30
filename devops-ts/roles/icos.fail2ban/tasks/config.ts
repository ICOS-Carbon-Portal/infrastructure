import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create fail2ban config files",
    copy: {
      dest: "{{ item.dest }}",
      content: "{{ item.content }}",
    },
    loop: V.fail2ban_config_files,
    loop_control: {
      label: "{{ item.dest }}",
    },
    notify: "fail2ban reload",
  },
] satisfies TaskFile;
