import { certbot_disabled } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { not } from "../../../lib/vars.ts";

export default [
  {
    import_tasks: "certbot.yml",
    tags: "certbot_only",
    when: not(certbot_disabled),
  },
] satisfies TaskFile;
