import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Install resolvconf",
    apt: {
      name: "resolvconf",
      state: "present",
    },
  },
  {
    name: "Install unbound",
    apt: {
      name: "unbound",
      state: "present",
    },
  },
] satisfies TaskFile;
