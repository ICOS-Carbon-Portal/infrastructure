import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Copy ops-zrepl",
    template: {
      src: "ops-zrepl",
      dest: "/usr/local/sbin/",
      mode: "+x",
      variable_start_string: "{{ '{{{' }}",
      variable_end_string: "{{ '}}}' }}",
      lstrip_blocks: true,
    },
    register: "_justfile",
  },
  {
    name: "Check that the justfile is executable",
    shell: "{{ _justfile.dest }}",
    changed_when: false,
  },
] satisfies TaskFile;
