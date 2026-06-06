import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "restart rspamd",
    systemd: {
      name: "rspamd",
      state: "restarted",
    },
  },
] satisfies TaskFile;
