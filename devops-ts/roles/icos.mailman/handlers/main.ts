import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload nginx config",
    service: "name=nginx state=reloaded",
  },
] satisfies TaskFile;
