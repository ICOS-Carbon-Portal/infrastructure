import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Install smartmontools",
    apt: { name: ["smartmontools"] },
  },
  {
    name: "Allow the telegraf user to sudo /usr/sbin/smartctl",
    "community.general.sudoers": {
      name: "allow-telegraf-smart",
      state: "present",
      user: "telegraf",
      commands: "/usr/sbin/smartctl",
    },
  },
] satisfies TaskFile;
