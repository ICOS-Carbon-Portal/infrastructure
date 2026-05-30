import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart icos timer",
    systemd: {
      name: "{{ timer_name }}.timer",
      state: "restarted",
    },
  },
] satisfies TaskFile;
