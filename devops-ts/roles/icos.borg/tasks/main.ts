import { borg_upgrade } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { borg_bin } from "../../../lib/globals.ts";
import { register } from "../../../lib/register.ts";
import { not, or, truthy } from "../../../lib/vars.ts";

const _r = register("_r");

export default [
  {
    name: "Check whether borg is installed",
    stat: {
      path: borg_bin,
    },
    register: _r,
  },
  {
    name: "Install/upgrade borg",
    include_tasks: {
      file: "install.yml",
    },
    when: or(not(_r.stat.exists), truthy(borg_upgrade)),
  },
  {
    import_tasks: "just.yml",
    tags: "borg_just",
  },
] satisfies TaskFile;
