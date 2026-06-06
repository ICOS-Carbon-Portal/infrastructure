import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "restart icos timer",
    systemd: {
      name: tmpl`${V.timer_name}.timer`,
      state: "restarted",
    },
  },
] satisfies TaskFile;
