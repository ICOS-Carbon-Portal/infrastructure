import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload systemd config",
    systemd: {
      daemon_reload: true,
    },
  },
] satisfies TaskFile;
