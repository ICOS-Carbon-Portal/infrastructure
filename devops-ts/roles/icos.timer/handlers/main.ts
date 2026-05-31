import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { notVar, tmpl } from "../_ctx.ts";

export default [
  {
    name: "restart icos timer",
    when: notVar("ansible_check_mode"),
    systemd: {
      name: tmpl("{{ timer_name }}.timer"),
      state: "restarted",
    },
  },
] satisfies TaskFile;
