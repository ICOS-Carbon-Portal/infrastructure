import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOverVar } from "../../../lib/loop.ts";
import { nginxforward_users } from "../../../lib/paramvars.ts";

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
    nginxforward_users,
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
