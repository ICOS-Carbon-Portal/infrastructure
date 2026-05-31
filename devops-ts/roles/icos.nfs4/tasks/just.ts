import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Copy ops-nfs",
    template: {
      src: "ops-nfs",
      dest: "/usr/local/bin/",
      mode: "+x",
      variable_start_string: tmpl("{{ '{{{' }}"),
      variable_end_string: tmpl("{{ '}}}' }}"),
      lstrip_blocks: true,
    },
    register: "_justfile",
  },
  {
    name: "Check that the justfile is executable",
    shell: tmpl("{{ _justfile.dest }}"),
    changed_when: false,
  },
] satisfies TaskFile;
