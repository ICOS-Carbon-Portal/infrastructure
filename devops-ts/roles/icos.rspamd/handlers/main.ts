import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart rspamd",
    systemd: {
      name: "rspamd",
      state: "restarted",
    },
  },
] satisfies TaskFile;
