import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  { include_role: { name: "icos.certbot" } },
  {
    name: "Copy nginx conf",
    template: {
      src: "sites-aquanet-form.conf",
      dest: "/etc/nginx/conf.d/",
      mode: 0o700,
    },
    notify: "reload nginx config",
  },
] satisfies TaskFile;
