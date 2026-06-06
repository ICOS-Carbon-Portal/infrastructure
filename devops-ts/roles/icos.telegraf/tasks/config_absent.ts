import { telegraf_config_file, telegraf_config_root } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { type When } from "../../../lib/ansible/task.ts";
import { tmpl } from "../../../lib/template.ts";
import { eq } from "../../../lib/vars.ts";

export default [
  {
    name: "Fail if user is trying to remove main config file",
    fail: { msg: "Refusing to remove main config file." },
    when: [eq(telegraf_config_file, "telegraf.conf")] as unknown as When,
  },
  {
    name: "Remove telegraf config file",
    file: {
      name: tmpl`${telegraf_config_root}/${telegraf_config_file}`,
      state: "absent",
    },
    notify: "reload telegraf",
  },
] satisfies TaskFile;
