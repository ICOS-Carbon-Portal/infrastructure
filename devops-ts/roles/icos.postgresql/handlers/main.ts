import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "reload postgresql",
    systemd: {
      name: "postgresql",
      status: "reloaded",
    },
  },
  {
    name: "restart postgresql",
    systemd: {
      name: "postgresql",
      status: "restarted",
    },
  },
] satisfies TaskFile;
