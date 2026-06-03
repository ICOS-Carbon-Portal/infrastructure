import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${V.item} needs to be defined` },
    when: raw("vars[item] is undefined"),
    loop: ["jupyter_domain"],
  },
  {
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.jupyter_domain,
      certbot_domains: [V.jupyter_domain],
    },
  },
  {
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_file: "jupyter-nginx.conf",
      jupyter_cert_name: V.jupyter_domain,
    },
  },
] satisfies TaskFile;
