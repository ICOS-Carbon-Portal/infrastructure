import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "restart filedrop",
    systemd: {
      name: "filedrop",
      state: "restarted",
    },
  },
] satisfies TaskFile;
