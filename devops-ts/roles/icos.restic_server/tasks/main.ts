import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { not, or, truthy } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

const _r = register("_r");

export default [
  { import_tasks: "setup.yml", tags: "restic_server_setup" },
  {
    name: "Check whether restic-rest is installed",
    stat: { path: V.restic_server_exec },
    register: _r,
  },
  {
    name: "Install/upgrade restic-rest server",
    include_tasks: { file: "install.yml" },
    when: or(not(_r.stat.exists), truthy(V.restic_server_upgrade)),
  },
  { import_tasks: "systemd.yml", tags: "restic_server_systemd" },
  { import_tasks: "just.yml", tags: "restic_server_just" },
  { import_tasks: "auth.yml", tags: "restic_server_auth" },
] satisfies TaskFile;
