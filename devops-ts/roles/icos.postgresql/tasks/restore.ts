import { type TaskFile, V } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl`Extract "${V.postgresql_container_name}" backup`,
    "ansible.builtin.shell": {
      cmd:
        tmpl`/usr/local/bin/restore_${V.postgresql_container_name}_db.py --host=${V.postgresql_backup_host} --location=${V.postgresql_backup_location}`,
      // executable: /usr/bin/python3
    },
  },
] satisfies TaskFile;
