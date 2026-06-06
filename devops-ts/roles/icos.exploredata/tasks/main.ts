import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    include_tasks: "setup.yml",
    loop: ["test", "prod"],
    loop_control: {
      loop_var: "exploredata_type",
    },
  },
] satisfies TaskFile;
