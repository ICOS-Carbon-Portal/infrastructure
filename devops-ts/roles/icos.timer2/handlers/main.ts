import { type TaskFile, V } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "restart icos timer",
    systemd: {
      name: tmpl`${V.timer_name}.timer`,
      state: "restarted",
    },
  },
] satisfies TaskFile;
