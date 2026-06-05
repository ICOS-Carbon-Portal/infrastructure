import { ne, not, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const r = register("r");

export default [
  {
    name: "Stop and disable timer",
    command: tmpl`systemctl disable --now ${V.timer_name}.timer`,
    register: r,
    changed_when: false,
    failed_when: [
      ne(r.rc, 0),
      not(r.stderr.endswith("does not exist.")),
    ],
  },
  {
    name: "Remove home directory",
    when: ne(V.timer_home, "/etc/systemd/systemd"),
    file: {
      path: V.timer_home,
      state: "absent",
    },
  },
] satisfies TaskFile;
