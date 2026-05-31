import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { notVar, rawTmpl, tmpl, V } from "../_ctx.ts";

export default [
  {
    import_tasks: "certbot_live.yml",
    when: notVar("certbot_fake_certificate"),
  },
  {
    import_tasks: "certbot_fake.yml",
    when: raw("certbot_fake_certificate"),
  },
  // The certbot_nginx_conf variable is set by either the live or fake path.
  {
    name: "Export certbot nginx config variable with prefix name",
    set_fact: tmpl`${V.certbot_conf_name}_certbot_nginx_conf="${
      rawTmpl("{{certbot_nginx_conf}}")
    }"`,
  },
] satisfies TaskFile;
