import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "install.yml", tags: "dokku_install" },
  { import_tasks: "just.yml", tags: "dokku_just" },
] satisfies TaskFile;
