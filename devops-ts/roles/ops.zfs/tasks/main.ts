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
    import_tasks: "just.yml",
    tags: "zfs_just",
  },
  {
    name: "Check whether httm is installed",
    tags: "httm",
    stat: {
      path: "/usr/bin/httm",
    },
    register: _r,
  },
  {
    name: "Install/upgrade httm",
    tags: "httm",
    include_tasks: {
      file: "httm.yml",
    },
    when: or(not(_r.stat.exists), truthy(V.httm_upgrade)),
  },
] satisfies TaskFile;
