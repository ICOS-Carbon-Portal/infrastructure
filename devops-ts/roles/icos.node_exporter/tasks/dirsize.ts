import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create dirsize home directory",
    file: {
      path: V.dirsize_home,
      state: "directory",
    },
  },
  {
    name: "Make sure that the dirnames file exists.",
    copy: {
      dest: V.dirsize_dirnames,
      force: false,
      content: "",
    },
  },
  {
    name: "Ensure that initial directories are in dirnames.txt",
    lineinfile: {
      path: V.dirsize_dirnames,
      line: V.item,
      state: "present",
    },
    loop: V.dirsize_initial,
  },
  {
    name: "Create timer for node-exporter-dirsize",
    include_role: {
      name: "icos.timer",
    },
    vars: {
      timer_home: V.dirsize_home,
      timer_name: "node-exporter-dirsize",
      timer_conf: "OnCalendar=hourly",
      timer_content: `#!/bin/bash
# Read directory name from a file that can be dynamically populated by
# ansible.
xargs -r -a {{ dirsize_dirnames }} {{ dirsize_sh }} | uniq | sponge {{ dirsize_prom }}
`,
    },
  },
] satisfies TaskFile;
