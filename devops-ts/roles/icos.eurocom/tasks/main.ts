import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { eurocom_users } from "../../../lib/paramvars.ts";
import { isDefined } from "../../../lib/vars.ts";

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
      nginxauth_users: eurocom_users,
    },
    when: isDefined(eurocom_users),
  },
  {
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: "eurocom",
      nginxsite_file: "roles/icos.eurocom/templates/eurocom.conf",
    },
  },
] satisfies TaskFile;
