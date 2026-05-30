import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Copy utilities",
    copy: {
      src: "{{ item }}",
      dest: "/usr/local/sbin/{{ item }}",
      mode: 0o755,
    },
    loop: ["lxdfs"],
  },
] satisfies TaskFile;
