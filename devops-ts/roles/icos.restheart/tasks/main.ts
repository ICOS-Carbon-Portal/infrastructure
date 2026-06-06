import { type TaskFile } from "../../../lib/ansible/play.ts";
import { restheart_backup_enable } from "../../../lib/globals.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    import_tasks: "setup.yml",
    become: true,
    become_user: "root",
    tags: "restheart_setup",
  },
  {
    import_tasks: "backup.yml",
    tags: "restheart_backup",
    when: truthy(restheart_backup_enable).default(false),
  },
] satisfies TaskFile;
