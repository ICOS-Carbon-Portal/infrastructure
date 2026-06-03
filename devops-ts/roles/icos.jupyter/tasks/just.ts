import { register, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

const _justfile = register("_justfile");
const _symlink = register("_symlink");

export default [
  {
    name: "Copy justfile",
    template: {
      src: "justfile",
      dest: V.jupyter_home,
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
      dest: "/usr/local/bin/ops-jupyter",
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
