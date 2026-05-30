import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: "{{ item }} needs to be defined" },
    when: raw("vars[item] is undefined"),
    loop: [
      "nginxsite_name",
    ],
  },
  {
    name: "Remove config file",
    file: {
      dest: "{{ item }}",
      state: "absent",
    },
    loop: [
      "{{ nginxsite_path_enable }}",
      "{{ nginxsite_path_available }}",
      "{{ nginxsite_path_confd }}",
    ],
  },
  {
    name: "Reload nginx",
    systemd: {
      name: "nginx",
      state: "reloaded",
    },
    changed_when: false,
  },
] satisfies TaskFile;
