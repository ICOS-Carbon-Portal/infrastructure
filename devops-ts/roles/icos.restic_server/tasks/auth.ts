import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Add restic users",
    htpasswd: {
      path: V.restic_server_htpasswd,
      crypt_scheme: "bcrypt",
      name: expr("item.name"),
      password: expr("item.password"),
      state: expr("item.state | default(omit)"),
    },
    loop: V.restic_server_users,
  },
] satisfies TaskFile;
