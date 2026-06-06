import { cpauth_home, cpauth_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Create cpauth user",
    user: {
      name: cpauth_user,
      home: cpauth_home,
      shell: "/bin/bash",
    },
  },
  {
    name: "Copy keys",
    copy: {
      src: "privateKeys",
      dest: cpauth_home,
      owner: cpauth_user,
    },
  },
] satisfies TaskFile;
