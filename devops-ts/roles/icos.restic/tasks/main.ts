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
