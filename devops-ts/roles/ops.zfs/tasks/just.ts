import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Copy ops-zfs",
    copy: {
      src: "ops-zfs",
      dest: "/usr/local/bin/ops-zfs",
      mode: "+x",
    },
    register: "_justfile",
  },
  {
    name: "Check that the justfile is executable",
    shell: "{{ _justfile.dest }}",
    changed_when: false,
  },
] satisfies TaskFile;
