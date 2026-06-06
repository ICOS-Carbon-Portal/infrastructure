import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    import_tasks: "barebones.yml",
    tags: "rdflog_setup",
  },
] satisfies TaskFile;
