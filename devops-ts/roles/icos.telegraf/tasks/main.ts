import { telegraf_smart_enable } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  { import_tasks: "install.yml", tags: "telegraf_install" },
  {
    import_tasks: "smart.yml",
    tags: "telegraf_smart",
    when: truthy(telegraf_smart_enable),
  },
  { import_tasks: "config.yml", tags: "telegraf_config" },
  { import_tasks: "just.yml", tags: "telegraf_just" },
] satisfies TaskFile;
