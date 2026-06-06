import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Install local flexpart script",
    copy: {
      dest: "/usr/local/bin/flexpart",
      mode: 0o755,
      content: `#/usr/bin/bash
exec ssh -q flexpart "$@"
`,
    },
  },
  {
    name: "Install local start-all-flexpart script",
    copy: {
      dest: "/usr/local/bin/start-all-flexpart",
      src: "start-all-flexpart.sh",
      mode: 0o755,
    },
  },
  {
    include_tasks: "flexpart_ssh_user.yml",
    loop: V.flexpart_ssh_users,
    loop_control: {
      loop_var: "_ssh_user",
    },
  },
] satisfies TaskFile;
