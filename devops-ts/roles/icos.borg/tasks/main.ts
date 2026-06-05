import {
  not,
  or,
  register,
  type TaskFile,
  truthy,
} from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

const _r = register("_r");

export default [
  {
    name: "Check whether borg is installed",
    stat: {
      path: V.borg_bin,
    },
    register: _r,
  },
  {
    name: "Install/upgrade borg",
    include_tasks: {
      file: "install.yml",
    },
    when: or(not(_r.stat.exists), truthy(V.borg_upgrade)),
  },
  {
    import_tasks: "just.yml",
    tags: "borg_just",
  },
] satisfies TaskFile;
