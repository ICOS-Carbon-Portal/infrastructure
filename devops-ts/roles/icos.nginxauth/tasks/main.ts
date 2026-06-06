import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOverVar } from "../../../lib/loop.ts";
import { isUndefined, varByName } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${V.item} needs to be defined` },
    when: isUndefined(varByName(V.item)),
    loop: ["nginxauth_users", "nginxauth_name"],
  },
  {
    name: "Install apache2-utils",
    apt: { name: "apache2-utils" },
  },
  {
    name: "Install the passlib library",
    apt: { name: "python3-passlib" },
  },
  {
    name: "Create directory for auth file",
    file: {
      path: V.nginxauth_file.dirname(),
      state: "directory",
    },
  },
  loopOverVar<{ password: string; username: string }>(
    V.nginxauth_users,
    (item) => ({
      name: "Add basic auth users",
      htpasswd: {
        path: V.nginxauth_file,
        name: item.username,
        password: item.password,
      },
    }),
  ),
] satisfies TaskFile;
