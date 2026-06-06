import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  postgresql_backup_host,
  postgresql_backup_location,
  postgresql_container_name,
} from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: tmpl`Extract "${postgresql_container_name}" backup`,
    "ansible.builtin.shell": {
      cmd:
        tmpl`/usr/local/bin/restore_${postgresql_container_name}_db.py --host=${postgresql_backup_host} --location=${postgresql_backup_location}`,
      // executable: /usr/bin/python3
    },
  },
] satisfies TaskFile;
