import { raw, type TaskFile } from "../../../lib/ansible.ts";

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
    register: "_r",
  },
  {
    name: "Install/upgrade httm",
    tags: "httm",
    include_tasks: {
      file: "httm.yml",
    },
    when: raw("not _r.stat.exists or httm_upgrade"),
  },
] satisfies TaskFile;
