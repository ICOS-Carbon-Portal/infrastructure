import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "reload nginx config",
    shell: `nginx -t && systemctl reload nginx
`,
  },
] satisfies TaskFile;
