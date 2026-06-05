import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

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
    when: truthy(V.restheart_backup_enable).default(false),
  },
] satisfies TaskFile;
