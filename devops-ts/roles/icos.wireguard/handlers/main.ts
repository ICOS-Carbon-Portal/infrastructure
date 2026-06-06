import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "systemd daemon-reload",
    systemd: {
      "daemon-reload": true,
    },
  },
] satisfies TaskFile;
