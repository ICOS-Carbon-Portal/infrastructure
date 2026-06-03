import { register, type TaskFile } from "../../../lib/ansible.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy ops-docker",
    copy: {
      src: "ops-docker",
      dest: "/usr/local/bin/",
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
