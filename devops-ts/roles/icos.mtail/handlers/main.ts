import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload mtail",
    service: {
      name: "mtail",
      state: "restarted",
    },
  },
] satisfies TaskFile;
