import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy justfile",
    copy: {
      src: "ops-caddy",
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
