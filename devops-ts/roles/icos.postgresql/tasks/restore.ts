import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl`Extract "${expr("postgresql_container_name")}" backup`,
    "ansible.builtin.shell": {
      cmd: tmpl`/usr/local/bin/restore_${
        expr("postgresql_container_name")
      }_db.py --host=${expr("postgresql_backup_host")} --location=${
        expr("postgresql_backup_location")
      }`,
      // executable: /usr/bin/python3
    },
  },
] satisfies TaskFile;
