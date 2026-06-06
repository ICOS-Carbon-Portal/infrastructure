import { type TaskFile } from "../../../lib/ansible/play.ts";
import { notVar, tmpl, V } from "../_ctx.ts";

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
