import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart rsync",
    service: { name: "rsync", state: "restarted" },
  },
] satisfies TaskFile;
