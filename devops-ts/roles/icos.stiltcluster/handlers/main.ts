import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart stiltcluster",
    systemd: {
      name: "stiltcluster",
      state: "restarted",
    },
  },
] satisfies TaskFile;
