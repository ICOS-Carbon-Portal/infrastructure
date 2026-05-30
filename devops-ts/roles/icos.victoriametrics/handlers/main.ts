import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload docker",
    service: {
      name: "docker",
      state: "reloaded",
    },
  },
] satisfies TaskFile;
