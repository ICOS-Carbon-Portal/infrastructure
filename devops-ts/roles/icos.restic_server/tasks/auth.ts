import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Add restic users",
    htpasswd: {
      path: V.restic_server_htpasswd,
      crypt_scheme: "bcrypt",
      name: "{{ item.name }}",
      password: "{{ item.password }}",
      state: "{{ item.state | default(omit) }}",
    },
    loop: V.restic_server_users,
  },
] satisfies TaskFile;
