import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";

export default [
  {
    name: "Create bin directory",
    file: {
      path: V.bbclient_bin_dir,
      state: "directory",
    },
  },
  {
    name: "Install borg wrapper that contains our ssh info",
    copy: {
      mode: "+x",
      dest: V.bbclient_wrapper,
      content: `#!/bin/bash
export BORG_RSH="{{ bbclient_ssh_bin }}"
export BORG_BASE_DIR="{{ bbclient_borg_dir }}"
exec {{ borg_bin }} "$@"
`,
    },
  },
  {
    name: "Create helper scripts",
    template: {
      src: item,
      dest: V.bbclient_bin_dir,
      mode: "+x",
    },
    loop: ["bbclient", "bbclient-all"],
  },
] satisfies TaskFile;
