import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Add restic users",
    htpasswd: {
      path: V.restic_server_htpasswd,
      crypt_scheme: "bcrypt",
      name: tmpl("{{ item.name }}"),
      password: tmpl("{{ item.password }}"),
      state: tmpl("{{ item.state | default(omit) }}"),
    },
    loop: V.restic_server_users,
  },
] satisfies TaskFile;
