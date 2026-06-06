import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { jinjaLiteral } from "../../../lib/template.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy ops-nfs",
    template: {
      src: "ops-nfs",
      dest: "/usr/local/bin/",
      mode: "+x",
      variable_start_string: jinjaLiteral("{{{"),
      variable_end_string: jinjaLiteral("}}}"),
      lstrip_blocks: true,
    },
    register: _justfile,
  },
  {
    name: "Check that the justfile is executable",
    shell: _justfile.dest.ref,
    changed_when: false,
  },
] satisfies TaskFile;
