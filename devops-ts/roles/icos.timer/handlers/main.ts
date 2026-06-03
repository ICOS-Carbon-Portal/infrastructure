import { type TaskFile, V } from "../../../lib/ansible.ts";
import { notVar, tmpl } from "../_ctx.ts";

export default [
  {
    name: "restart icos timer",
    when: notVar("ansible_check_mode"),
    systemd: {
      name: tmpl`${V.timer_name}.timer`,
      state: "restarted",
    },
  },
] satisfies TaskFile;
