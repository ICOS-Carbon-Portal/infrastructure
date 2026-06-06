import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "reload docker",
    service: {
      name: "docker",
      state: "reloaded",
    },
  },
] satisfies TaskFile;
