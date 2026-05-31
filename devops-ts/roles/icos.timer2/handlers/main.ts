import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "restart icos timer",
    systemd: {
      name: tmpl("{{ timer_name }}.timer"),
      state: "restarted",
    },
  },
] satisfies TaskFile;
