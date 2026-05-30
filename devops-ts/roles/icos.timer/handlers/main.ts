import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart icos timer",
    when: raw("not ansible_check_mode"),
    systemd: {
      name: "{{ timer_name }}.timer",
      state: "restarted",
    },
  },
] satisfies TaskFile;
