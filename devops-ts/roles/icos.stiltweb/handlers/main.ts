import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "reload systemd config",
    systemd: {
      daemon_reload: true,
    },
  },
] satisfies TaskFile;
