import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "setup.yml", tags: "restic_server_setup" },
  {
    name: "Check whether restic-rest is installed",
    stat: { path: V.restic_server_exec },
    register: "_r",
  },
  {
    name: "Install/upgrade restic-rest server",
    include_tasks: { file: "install.yml" },
    when: raw("not _r.stat.exists or restic_server_upgrade"),
  },
  { import_tasks: "systemd.yml", tags: "restic_server_systemd" },
  { import_tasks: "just.yml", tags: "restic_server_just" },
  { import_tasks: "auth.yml", tags: "restic_server_auth" },
] satisfies TaskFile;
