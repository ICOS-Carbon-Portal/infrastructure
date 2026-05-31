import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, rawTmpl, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Copy ops-zrepl",
    template: {
      src: "ops-zrepl",
      dest: "/usr/local/sbin/",
      mode: "+x",
      variable_start_string: rawTmpl("{{ '{{{' }}"),
      variable_end_string: rawTmpl("{{ '}}}' }}"),
      lstrip_blocks: true,
    },
    register: "_justfile",
  },
  {
    name: "Check that the justfile is executable",
    shell: expr("_justfile.dest"),
    changed_when: false,
  },
] satisfies TaskFile;
