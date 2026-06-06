import { type TaskFile } from "../../../lib/ansible/play.ts";
import { timer_name } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "restart icos timer",
    systemd: {
      name: tmpl`${timer_name}.timer`,
      state: "restarted",
    },
  },
] satisfies TaskFile;
