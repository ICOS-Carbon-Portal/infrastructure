import { lt, register, type TaskFile } from "../../../lib/ansible.ts";

const _r = register("_r");

export default [
  {
    name: "reload systemd config",
    systemd: {
      daemon_reload: true,
    },
  },
  {
    name: "restart cron",
    service: {
      name: "cron",
      state: "restarted",
    },
    register: _r,
    failed_when: [
      _r.failed,
      lt(_r.msg.find("Could not find the requested service cron"), 0),
    ],
  },
] satisfies TaskFile;
