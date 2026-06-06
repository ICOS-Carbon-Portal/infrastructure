import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  { import_tasks: "auto_dnat.yml", tags: "auto_dnat" },
  { import_tasks: "just.yml", tags: "pve_server_just" },
] satisfies TaskFile;
