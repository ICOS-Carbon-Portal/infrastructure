import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Check whether borg is installed",
    stat: {
      path: V.borg_bin,
    },
    register: "_r",
  },
  {
    name: "Install/upgrade borg",
    include_tasks: {
      file: "install.yml",
    },
    when: raw("not _r.stat.exists or borg_upgrade"),
  },
  {
    import_tasks: "just.yml",
    tags: "borg_just",
  },
] satisfies TaskFile;
