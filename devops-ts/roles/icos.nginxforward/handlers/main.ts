import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload nginx config",
    shell: `nginx -t && systemctl reload nginx
`,
  },
] satisfies TaskFile;
