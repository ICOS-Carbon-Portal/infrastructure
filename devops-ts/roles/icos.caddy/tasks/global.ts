import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    import_tasks: "config.yml",
    vars: {
      block: V.caddy_global_conf,
      marker: "caddy_global_conf",
      where: "BOF",
    },
  },
] satisfies TaskFile;
