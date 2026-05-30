import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Remove old stiltweb justfile",
    file: { name: "{{ stiltweb_home }}/justfile", state: "absent" },
  },
  {
    name: "Copy justfile",
    template: {
      src: "justfile",
      mode: "+x",
      dest: "/usr/local/bin/icos-stiltweb",
      variable_start_string: "((",
      variable_end_string: "))",
      lstrip_blocks: true,
    },
    register: "_justfile",
  },
  {
    name: "Check justfile",
    shell: "icos-stiltweb",
    changed_when: false,
  },
] satisfies TaskFile;
