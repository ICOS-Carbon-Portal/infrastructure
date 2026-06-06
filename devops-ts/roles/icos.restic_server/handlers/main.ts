import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "restart restic",
    systemd: {
      daemon_reload: true,
      name: "restic-server.socket",
      state: "restarted",
    },
  },
] satisfies TaskFile;
