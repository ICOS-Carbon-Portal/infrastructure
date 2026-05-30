import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { notVar } from "../_ctx.ts";

export default [
  {
    import_tasks: "certbot.yml",
    tags: "certbot_only",
    when: notVar("certbot_disabled"),
  },
] satisfies TaskFile;
