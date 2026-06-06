import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create stiltcluster configuration file",
    template: {
      dest: V.stiltcluster_home,
      src: "local.conf",
    },
    notify: "restart stiltcluster",
  },
] satisfies TaskFile;
