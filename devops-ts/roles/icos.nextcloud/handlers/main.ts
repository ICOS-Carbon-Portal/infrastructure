import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "reload nginx config",
    systemd: {
      name: "nginx",
      state: "reloaded",
    },
  },
] satisfies TaskFile;
