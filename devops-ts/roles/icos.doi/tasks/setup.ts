import { doi_home, doi_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Create doi user",
    user: {
      name: doi_user,
      home: doi_home,
      shell: "/bin/bash",
    },
  },
] satisfies TaskFile;
