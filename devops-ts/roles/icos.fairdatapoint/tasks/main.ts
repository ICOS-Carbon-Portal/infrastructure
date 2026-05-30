import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    import_tasks: "setup.yml",
    tags: "fairdatapoint_setup",
  },
] satisfies TaskFile;
