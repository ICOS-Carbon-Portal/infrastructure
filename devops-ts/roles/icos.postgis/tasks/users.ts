import { loopOverVar, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  loopOverVar<{ password: string; username: string }>(
    V.postgis_db_users,
    (item) => ({
      name: "Create postgres db users",
      become: true,
      postgresql_user: {
        db: V.db_name,
        name: item.username,
        password: item.password,
        login_user: V.postgis_db_user,
        login_password: V.postgis_db_pass,
        login_host: "127.0.0.1",
        login_port: V.postgis_db_port,
      },
    }),
  ),
] satisfies TaskFile;
