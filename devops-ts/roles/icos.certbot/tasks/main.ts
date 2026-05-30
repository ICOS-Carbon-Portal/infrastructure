import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    import_tasks: "certbot.yml",
    tags: "certbot_only",
    when: raw("not certbot_disabled"),
  },
] satisfies TaskFile;
