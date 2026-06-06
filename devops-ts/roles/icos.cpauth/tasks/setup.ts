import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create cpauth user",
    user: {
      name: V.cpauth_user,
      home: V.cpauth_home,
      shell: "/bin/bash",
    },
  },
  {
    name: "Copy keys",
    copy: {
      src: "privateKeys",
      dest: V.cpauth_home,
      owner: V.cpauth_user,
    },
  },
] satisfies TaskFile;
