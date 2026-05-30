import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload nginx config",
    systemd: {
      name: "nginx",
      state: "reloaded",
    },
  },
] satisfies TaskFile;
