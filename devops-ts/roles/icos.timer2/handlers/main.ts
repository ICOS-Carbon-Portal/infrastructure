import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "restart icos timer",
    systemd: {
      name: tmpl`${expr("timer_name")}.timer`,
      state: "restarted",
    },
  },
] satisfies TaskFile;
