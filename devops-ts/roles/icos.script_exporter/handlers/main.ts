import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload script-exporter",
    systemd: {
      name: "script-exporter",
      state: "reloaded",
    },
  },
] satisfies TaskFile;
