import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Copy ops-borg",
    copy: {
      src: "ops-borg",
      dest: "/usr/local/bin/ops-borg",
      mode: "+x",
    },
    register: "_justfile",
  },
  {
    name: "Check that the justfile is executable",
    shell: expr("_justfile.dest"),
    changed_when: false,
  },
] satisfies TaskFile;
