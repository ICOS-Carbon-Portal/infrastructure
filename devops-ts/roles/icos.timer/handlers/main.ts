import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_check_mode } from "../../../lib/builtins.ts";
import { timer_name } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { not } from "../../../lib/vars.ts";

export default [
  {
    name: "restart icos timer",
    when: not(ansible_check_mode),
    systemd: {
      name: tmpl`${timer_name}.timer`,
      state: "restarted",
    },
  },
] satisfies TaskFile;
