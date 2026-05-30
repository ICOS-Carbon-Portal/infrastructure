import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Stop and disable timer",
    command: "systemctl disable --now {{ timer_name }}.timer",
    register: "r",
    changed_when: false,
    failed_when: [
      "r.rc != 0",
      "not r.stderr.endswith('does not exist.')",
    ],
  },
  {
    name: "Remove home directory",
    when: raw('timer_home != "/etc/systemd/systemd"'),
    file: {
      path: "{{ timer_home }}",
      state: "absent",
    },
  },
] satisfies TaskFile;
