import { register, type TaskFile } from "../../../lib/ansible.ts";

const _justfile = register("_justfile");

export default [
  {
    name: "Copy ops-fail2ban",
    copy: {
      src: "ops-fail2ban",
      dest: "/usr/local/bin/ops-fail2ban",
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
