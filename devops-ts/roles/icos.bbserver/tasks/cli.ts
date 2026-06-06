import { randomInt, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl`Create ${V.bbserver_home}/bin directory`,
    file: {
      path: tmpl`${V.bbserver_home}/bin`,
      state: "directory",
      owner: V.bbserver_user,
      group: V.bbserver_user,
    },
  },
  {
    name: "Copy bbserver.py",
    template: {
      src: "bbserver.py",
      mode: "+x",
      dest: tmpl`${V.bbserver_home}/bin/bbserver`,
    },
  },
  {
    name: "Prime borg cache by running 'bbserver list' each night",
    cron: {
      user: "bbserver",
      job: tmpl`${V.bbserver_home}/bin/bbserver list > /dev/null 2>&1`,
      hour: randomInt(4, "bbserver"),
      minute: randomInt(60, "bbserver"),
      name: "bbserver_prime_borg_cache",
    },
  },
] satisfies TaskFile;
