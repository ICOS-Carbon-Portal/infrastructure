import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "restart zrepl",
    systemd: {
      name: "zrepl",
      state: "restarted",
    },
  },
] satisfies TaskFile;
