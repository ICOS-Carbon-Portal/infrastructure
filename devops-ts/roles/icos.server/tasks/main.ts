import { type TaskFile } from "../../../lib/ansible/play.ts";
import { isTruthy } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Install public keys",
    authorized_key: {
      user: "root",
      state: "present",
      key: V.root_keys,
      // Make sure to remove stale root keys
      exclusive: true,
    },
    when: isTruthy(V.root_keys),
  },
  {
    name: "Set timezone to Europe/Stockholm",
    timezone: { name: "Europe/Stockholm" },
    notify: "restart cron",
  },
  {
    name: "Generate locale",
    locale_gen: { name: V.item, state: "present" },
    loop: ["en_US.UTF-8", "sv_SE.UTF-8"],
  },
] satisfies TaskFile;
