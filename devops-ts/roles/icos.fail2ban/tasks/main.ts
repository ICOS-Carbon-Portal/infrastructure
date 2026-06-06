import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  { import_tasks: "setup.yml", tags: "fail2ban_setup" },
  { import_tasks: "just.yml", tags: "fail2ban_just" },
  { import_tasks: "config.yml", tags: "fail2ban_config" },
] satisfies TaskFile;
