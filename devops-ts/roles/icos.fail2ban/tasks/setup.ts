import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Install fail2ban",
    apt: {
      name: "fail2ban",
      state: "present",
    },
  },
  {
    name: "Enable fail2ban",
    service: {
      name: "fail2ban",
      state: "started",
      enabled: true,
    },
  },
] satisfies TaskFile;
