import { lt, register, type TaskFile } from "../../../lib/ansible.ts";

const _r = register("_r");

export default [
  {
    name: "restart cron",
    service: {
      name: "cron",
      state: "restarted",
    },
    register: _r,
    // cron might not be installed
    failed_when: [
      _r.failed,
      lt(_r.msg.find("Could not find the requested service cron"), 0),
    ],
  },
  {
    name: "reboot",
    reboot: {
      reboot_timeout: 120,
    },
  },
] satisfies TaskFile;
