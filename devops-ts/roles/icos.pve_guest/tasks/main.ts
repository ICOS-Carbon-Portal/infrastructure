import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  { import_tasks: "terminal.yml", tags: "pve_guest_terminal" },
  { import_tasks: "setup.yml", tags: "pve_guest_setup" },
  {
    name: "Install icos utilities",
    tags: "utils",
    import_role: {
      name: "icos.utils",
    },
  },
  {
    name: "Add users",
    tags: "users",
    import_role: {
      name: "icos.users",
    },
  },
] satisfies TaskFile;
