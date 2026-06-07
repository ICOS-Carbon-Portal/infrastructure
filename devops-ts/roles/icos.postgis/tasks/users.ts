import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { postgis_db_port } from "../../../lib/globals.ts";
import { loopOverVar } from "../../../lib/loop.ts";
import { db_name } from "../../../lib/paramvars.ts";

export default [
  loopOverVar<{ password: string; username: string }>(
    V.postgis_db_users,
    (item) => ({
      name: "Create postgres db users",
      become: true,
      postgresql_user: {
        db: db_name,
        name: item.username,
        password: item.password,
        login_user: V.postgis_db_user,
        login_password: V.postgis_db_pass,
        login_host: "127.0.0.1",
        login_port: postgis_db_port,
      },
    }),
  ),
] satisfies TaskFile;
