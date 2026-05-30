import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    import_tasks: "barebones.yml",
    tags: "rdflog_setup",
  },
] satisfies TaskFile;
