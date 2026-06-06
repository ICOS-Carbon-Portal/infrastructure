import { restic_server_htpasswd, restic_server_users } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { loopOverVar } from "../../../lib/loop.ts";

export default [
  loopOverVar<{ name: string; password: string; state: string }>(
    restic_server_users,
    (item) => ({
      name: "Add restic users",
      htpasswd: {
        path: restic_server_htpasswd,
        crypt_scheme: "bcrypt",
        name: item.name,
        password: item.password,
        state: item.state.default(omit),
      },
    }),
  ),
] satisfies TaskFile;
