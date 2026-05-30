import { raw, type TaskFile } from "../../../lib/ansible.ts";

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
    when: raw("restheart_backup_enable | default(False)"),
  },
] satisfies TaskFile;
