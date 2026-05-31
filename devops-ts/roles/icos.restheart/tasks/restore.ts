import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Restore RestHeart backup",
    "ansible.builtin.script": {
      cmd: tmpl`/usr/local/bin/restore_restheart_db.py --host=${
        expr("restheart_backup_host")
      } --location=${V.restheart_backup_location}`,
      executable: "/usr/bin/python3",
    },
  },
] satisfies TaskFile;
