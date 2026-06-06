import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "docker.yml", tags: "postgis_setup" },
  {
    name: "Install postgis restore script",
    tags: "postgis_restore_script",
    template: {
      src: "restore_postgis_db.py",
      dest: "/usr/local/bin/restore_postgis_db.py",
      mode: "+x",
    },
  },
  {
    import_tasks: "backup.yml",
    tags: "postgis_backup",
    when: truthy(V.postgis_backup_enable),
  },
  { import_tasks: "just.yml", tags: "postgis_just" },
] satisfies TaskFile;
