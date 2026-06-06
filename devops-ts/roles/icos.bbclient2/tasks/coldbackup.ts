import {
  bbclient_bin_dir,
  bbclient_coldbackup_hour,
  bbclient_coldbackup_minute,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { bbclient_home } from "../../../lib/globals.ts";
import { bbclient_name } from "../../../lib/sharedvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Install python3-click",
    apt: { name: "python3-click" },
  },
  {
    name: "Create coldbackup helper scripts",
    template: {
      src: item,
      dest: bbclient_bin_dir,
      mode: "+x",
    },
    loop: ["bbclient-coldbackup", "bbclient-coldrestore"],
  },
  {
    name: "Add coldbackup systemd timer",
    include_role: { name: "icos.timer" },
    vars: {
      timer_home: bbclient_home,
      timer_exec: tmpl`${bbclient_bin_dir}/bbclient-coldbackup`,
      timer_name: tmpl`bbclient-${bbclient_name}-coldbackup`,
      timer_conf:
        tmpl`OnCalendar=${bbclient_coldbackup_hour}:${bbclient_coldbackup_minute}\n`,
      timer_envs: ["PYTHONUNBUFFERED=1"],
    },
  },
] satisfies TaskFile;
