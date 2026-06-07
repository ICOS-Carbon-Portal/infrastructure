import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { not, or, truthy } from "../../../lib/vars.ts";

const _r = register("_r");

export default [
  {
    name: "Check whether just is installed",
    stat: { path: "/usr/local/bin/just" },
    register: _r,
  },
  {
    name: "Install/upgrade just",
    include_tasks: { file: "install.yml" },
    when: or(not(_r.stat.exists), truthy(V.just_upgrade)),
  },
  {
    name: "Create bash_completion.d directory",
    file: {
      path: "/etc/bash_completion.d",
      state: "directory",
    },
  },
  {
    name: "Add bash completions for just",
    "ansible.builtin.shell":
      `just --completions bash > /etc/bash_completion.d/just
`,
    args: {
      creates: "/etc/bash_completion.d/just",
      executable: "/bin/bash",
    },
  },
] satisfies TaskFile;
