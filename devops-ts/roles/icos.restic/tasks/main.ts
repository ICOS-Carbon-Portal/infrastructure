import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Check whether restic is installed",
    stat: {
      path: "/usr/local/bin/restic",
    },
    register: "_r",
  },
  {
    when: raw("not _r.stat.exists or restic_upgrade"),
    tags: "restic_install",
    name: "Install/upgrade restic",
    include_tasks: {
      file: "install.yml",
    },
  },
] satisfies TaskFile;
