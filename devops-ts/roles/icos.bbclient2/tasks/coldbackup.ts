import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install python3-click",
    apt: { name: "python3-click" },
  },
  {
    name: "Create coldbackup helper scripts",
    template: {
      src: V.item,
      dest: V.bbclient_bin_dir,
      mode: "+x",
    },
    loop: ["bbclient-coldbackup", "bbclient-coldrestore"],
  },
  {
    name: "Add coldbackup systemd timer",
    include_role: { name: "icos.timer" },
    vars: {
      timer_home: V.bbclient_home,
      timer_exec: tmpl`${V.bbclient_bin_dir}/bbclient-coldbackup`,
      timer_name: "bbclient-{{ bbclient_name }}-coldbackup",
      timer_conf:
        tmpl`OnCalendar=${V.bbclient_coldbackup_hour}:${V.bbclient_coldbackup_minute}\n`,
      timer_envs: ["PYTHONUNBUFFERED=1"],
    },
  },
] satisfies TaskFile;
