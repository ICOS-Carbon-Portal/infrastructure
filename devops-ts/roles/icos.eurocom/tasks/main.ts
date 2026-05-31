import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.eurocom_domain,
      certbot_domains: [
        V.eurocom_domain,
      ],
    },
  },
  {
    include_role: "name=icos.nginxauth",
    vars: {
      nginxauth_file: V.eurocom_auth_file,
      nginxauth_users: expr("eurocom_users"),
    },
    when: raw("eurocom_users is defined"),
  },
  {
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: "eurocom",
      nginxsite_file: "roles/icos.eurocom/templates/eurocom.conf",
    },
  },
] satisfies TaskFile;
