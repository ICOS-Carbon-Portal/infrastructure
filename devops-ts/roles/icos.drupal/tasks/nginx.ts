import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  { include_role: "name=icos.certbot" },
  {
    name: "Copy nginx {{ nginx_conf_name }}.conf",
    template: {
      src: "nginx.conf.j2",
      dest: "/etc/nginx/conf.d/{{ nginx_conf_name }}.conf",
      mode: 0o700,
    },
    notify: "reload nginx config",
  },
] satisfies TaskFile;
