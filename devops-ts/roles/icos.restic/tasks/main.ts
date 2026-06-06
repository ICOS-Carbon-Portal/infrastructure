import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { not, or, truthy } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

const _r = register("_r");

export default [
  {
    name: "Check whether restic is installed",
    stat: {
      path: "/usr/local/bin/restic",
    },
    register: _r,
  },
  {
    when: or(not(_r.stat.exists), truthy(V.restic_upgrade)),
    tags: "restic_install",
    name: "Install/upgrade restic",
    include_tasks: {
      file: "install.yml",
    },
  },
] satisfies TaskFile;
