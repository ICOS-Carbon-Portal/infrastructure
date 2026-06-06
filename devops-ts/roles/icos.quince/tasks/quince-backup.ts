import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "bbclient",
    import_role: {
      name: "icos.bbclient2",
    },
  },
  {
    name: "Copy quince-backup.sh",
    template: {
      src: "quince-backup.sh",
      dest: tmpl`${V.quince_home}/backup.sh`,
      mode: "+x",
    },
  },
  {
    name: "Install cron job for backups",
    cron: {
      user: V.quince_user,
      name: "quince borg backup",
      minute: "15",
      hour: "*/3",
      job: tmpl`${V.quince_home}/backup.sh`,
    },
    when: truthy(V.quince_backup_enable),
  },
] satisfies TaskFile;
