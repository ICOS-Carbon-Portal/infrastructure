import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "restart stiltcluster",
    systemd: {
      name: "stiltcluster",
      state: "restarted",
    },
  },
] satisfies TaskFile;
