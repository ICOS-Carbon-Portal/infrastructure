import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "restart rsync",
    service: { name: "rsync", state: "restarted" },
  },
] satisfies TaskFile;
