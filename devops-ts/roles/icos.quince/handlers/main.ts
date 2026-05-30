import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload systemd config",
    systemd: {
      daemon_reload: true,
    },
  },
  {
    name: "restart the quince service",
    systemd: {
      name: "quince",
      state: "restarted",
    },
  },
  {
    name: "restart rsyslog",
    systemd: {
      name: "rsyslog",
      state: "restarted",
    },
  },
] satisfies TaskFile;
