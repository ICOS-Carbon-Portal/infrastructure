import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  { include_role: "name=icos.certbot" },
  {
    name: tmpl`Copy nginx ${V.nginx_conf_name}.conf`,
    template: {
      src: "nginx.conf.j2",
      dest: tmpl`/etc/nginx/conf.d/${V.nginx_conf_name}.conf`,
      mode: 0o700,
    },
    notify: "reload nginx config",
  },
] satisfies TaskFile;
