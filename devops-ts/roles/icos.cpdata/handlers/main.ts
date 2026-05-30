import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "restart cpdata",
    service: {
      name: "cpdata",
      state: "restarted",
    },
  },
] satisfies TaskFile;
