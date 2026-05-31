import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Copy justfile",
    template: {
      src: "justfile",
      dest: V.vm_home,
      mode: "+x",
      variable_start_string: "((",
      variable_end_string: "))",
      lstrip_blocks: true,
    },
    register: "_justfile",
  },
  {
    name: "Create executable symlink to justfile",
    file: {
      dest: "/usr/local/bin/ops-victoriametrics",
      src: tmpl("{{ _justfile.dest }}"),
      state: "link",
    },
    register: "_symlink",
  },
  {
    name: "Check that the justfile is executable",
    shell: tmpl("{{ _symlink.dest }}"),
    changed_when: false,
  },
] satisfies TaskFile;
