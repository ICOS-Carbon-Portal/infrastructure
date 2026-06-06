import { nginxauth_file } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { loopOverVar } from "../../../lib/loop.ts";
import { nginxauth_users } from "../../../lib/sharedvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { isUndefined, varByName } from "../../../lib/vars.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${item} needs to be defined` },
    when: isUndefined(varByName(item)),
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
      path: nginxauth_file.dirname(),
      state: "directory",
    },
  },
  loopOverVar<{ password: string; username: string }>(
    nginxauth_users,
    (item) => ({
      name: "Add basic auth users",
      htpasswd: {
        path: nginxauth_file,
        name: item.username,
        password: item.password,
      },
    }),
  ),
] satisfies TaskFile;
