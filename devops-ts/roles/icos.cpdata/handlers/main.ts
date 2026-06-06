import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "restart cpdata",
    service: {
      name: "cpdata",
      state: "restarted",
    },
  },
] satisfies TaskFile;
