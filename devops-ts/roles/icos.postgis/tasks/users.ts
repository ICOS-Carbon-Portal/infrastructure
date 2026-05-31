import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create postgres db users",
    become: true,
    postgresql_user: {
      db: expr("db_name"),
      name: expr("item.username"),
      password: expr("item.password"),
      login_user: V.postgis_db_user,
      login_password: V.postgis_db_pass,
      login_host: "127.0.0.1",
      login_port: V.postgis_db_port,
    },
    loop: V.postgis_db_users,
  },
] satisfies TaskFile;
