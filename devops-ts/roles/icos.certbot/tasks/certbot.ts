import { certbot_fake_certificate } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  certbot_conf_name,
  certbot_nginx_conf,
} from "../../../lib/sharedvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { not, truthy } from "../../../lib/vars.ts";

export default [
  {
    import_tasks: "certbot_live.yml",
    when: not(certbot_fake_certificate),
  },
  {
    import_tasks: "certbot_fake.yml",
    when: truthy(certbot_fake_certificate),
  },
  // The certbot_nginx_conf variable is set by either the live or fake path.
  {
    name: "Export certbot nginx config variable with prefix name",
    set_fact:
      tmpl`${certbot_conf_name}_certbot_nginx_conf="${certbot_nginx_conf}"`,
  },
] satisfies TaskFile;
