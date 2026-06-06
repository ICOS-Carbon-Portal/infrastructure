import { restic_server_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";

const _justfile = register("_justfile");
const _symlink = register("_symlink");

export default [
  {
    name: "Copy justfile",
    template: {
      src: "justfile",
      dest: restic_server_home,
      mode: "+x",
      variable_start_string: "((",
      variable_end_string: "))",
      lstrip_blocks: true,
    },
    register: _justfile,
  },
  {
    name: "Create executable symlink to justfile",
    file: {
      dest: "/usr/local/bin/ops-restic-server",
      src: _justfile.dest.ref,
      state: "link",
    },
    register: _symlink,
  },
  {
    name: "Check that the justfile is executable",
    shell: _symlink.dest.ref,
    changed_when: false,
  },
] satisfies TaskFile;
