import { quince_backup_enable, quince_home, quince_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

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
      dest: tmpl`${quince_home}/backup.sh`,
      mode: "+x",
    },
  },
  {
    name: "Install cron job for backups",
    cron: {
      user: quince_user,
      name: "quince borg backup",
      minute: "15",
      hour: "*/3",
      job: tmpl`${quince_home}/backup.sh`,
    },
    when: truthy(quince_backup_enable),
  },
] satisfies TaskFile;
