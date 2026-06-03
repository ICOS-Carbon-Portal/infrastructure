import { type TaskFile } from "../../../lib/ansible.ts";
import { rawTmpl } from "../_ctx.ts";

export default [
  {
    name: "Copy ops-nebula.justfile",
    template: {
      src: "ops-nebula.justfile",
      dest: "/usr/local/bin/ops-nebula",
      mode: "+x",
      variable_start_string: rawTmpl("{{ '{{{' }}"),
      variable_end_string: rawTmpl("{{ '}}}' }}"),
      lstrip_blocks: true,
    },
  },
  {
    name: "Check that ops-nebula is executable",
    shell: "ops-nebula",
    changed_when: false,
  },
] satisfies TaskFile;
