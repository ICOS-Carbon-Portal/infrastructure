import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create doi user",
    user: {
      name: V.doi_user,
      home: V.doi_home,
      shell: "/bin/bash",
    },
  },
] satisfies TaskFile;
