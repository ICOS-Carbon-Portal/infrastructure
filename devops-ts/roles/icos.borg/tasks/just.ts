import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy ops-borg",
    copy: {
      src: "ops-borg",
      dest: "/usr/local/bin/ops-borg",
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
