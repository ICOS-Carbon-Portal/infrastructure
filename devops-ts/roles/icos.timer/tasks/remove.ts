import { timer_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { timer_name } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { ne, not } from "../../../lib/vars.ts";

const r = register("r");

export default [
  {
    name: "Stop and disable timer",
    command: tmpl`systemctl disable --now ${timer_name}.timer`,
    register: r,
    changed_when: false,
    failed_when: [
      ne(r.rc, 0),
      not(r.stderr.endswith("does not exist.")),
    ],
  },
  {
    name: "Remove home directory",
    when: ne(timer_home, "/etc/systemd/systemd"),
    file: {
      path: timer_home,
      state: "absent",
    },
  },
] satisfies TaskFile;
