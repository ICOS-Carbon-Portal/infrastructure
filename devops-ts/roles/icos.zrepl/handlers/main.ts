import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart zrepl",
    systemd: {
      name: "zrepl",
      state: "restarted",
    },
  },
] satisfies TaskFile;
