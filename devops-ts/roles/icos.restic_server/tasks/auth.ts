import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOverVar } from "../../../lib/loop.ts";
import { V } from "../_ctx.ts";

export default [
  loopOverVar<{ name: string; password: string; state: string }>(
    V.restic_server_users,
    (item) => ({
      name: "Add restic users",
      htpasswd: {
        path: V.restic_server_htpasswd,
        crypt_scheme: "bcrypt",
        name: item.name,
        password: item.password,
        state: item.state.default(V.omit),
      },
    }),
  ),
] satisfies TaskFile;
