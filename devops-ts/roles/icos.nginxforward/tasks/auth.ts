import { loopOverVar, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  // This gets us htpasswd(1)
  {
    name: "Install apache2-utils",
    apt: {
      name: "apache2-utils",
      state: "present",
    },
  },
  {
    name: "Install the passlib library",
    apt: {
      name: "python3-passlib",
    },
  },
  loopOverVar<{ name: string; password: string }>(
    V.nginxforward_users,
    (item) => ({
      name: "Add basic auth users",
      htpasswd: {
        path: V.nginxforward_user_file,
        name: item.name,
        password: item.password,
      },
    }),
  ),
] satisfies TaskFile;
