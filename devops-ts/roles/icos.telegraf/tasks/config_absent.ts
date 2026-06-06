import { type TaskFile } from "../../../lib/ansible/play.ts";
import { type When } from "../../../lib/ansible/task.ts";
import { eq } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Fail if user is trying to remove main config file",
    fail: { msg: "Refusing to remove main config file." },
    when: [eq(V.telegraf_config_file, "telegraf.conf")] as unknown as When,
  },
  {
    name: "Remove telegraf config file",
    file: {
      name: tmpl`${V.telegraf_config_root}/${V.telegraf_config_file}`,
      state: "absent",
    },
    notify: "reload telegraf",
  },
] satisfies TaskFile;
