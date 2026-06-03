import { register, type TaskFile } from "../../../lib/ansible.ts";
import { rawTmpl } from "../_ctx.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy ops-nfs",
    template: {
      src: "ops-nfs",
      dest: "/usr/local/bin/",
      mode: "+x",
      variable_start_string: rawTmpl("{{ '{{{' }}"),
      variable_end_string: rawTmpl("{{ '}}}' }}"),
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
