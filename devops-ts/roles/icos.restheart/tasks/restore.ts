import { type TaskFile } from "../../../lib/ansible/play.ts";
import { restheart_backup_location } from "../../../lib/globals.ts";
import { restheart_backup_host } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Restore RestHeart backup",
    "ansible.builtin.script": {
      cmd:
        tmpl`/usr/local/bin/restore_restheart_db.py --host=${restheart_backup_host} --location=${restheart_backup_location}`,
      executable: "/usr/bin/python3",
    },
  },
] satisfies TaskFile;
