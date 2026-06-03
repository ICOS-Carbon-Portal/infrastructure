import { register, type TaskFile } from "../../../lib/ansible.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy justfile",
    copy: {
      src: "ops-dokku",
      dest: "/usr/local/bin/ops-dokku",
      mode: "+x",
    },
    register: _justfile,
  },
  {
    name: "Check that the justfile is executable",
    shell: _justfile.dest.ref,
    changed_when: false,
  },
] satisfies TaskFile;
