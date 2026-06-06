import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy ops-zfs",
    copy: {
      src: "ops-zfs",
      dest: "/usr/local/bin/ops-zfs",
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
