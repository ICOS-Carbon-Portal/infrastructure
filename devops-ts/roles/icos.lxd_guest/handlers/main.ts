import { type TaskFile } from "../../../lib/ansible.ts";

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
    register: "_r",
    failed_when: [
      "_r.failed",
      "_r.msg.find('Could not find the requested service cron') < 0",
    ],
  },
] satisfies TaskFile;
