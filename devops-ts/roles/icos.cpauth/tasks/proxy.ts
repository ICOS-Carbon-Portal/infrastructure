import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create cpauth certificate",
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.cpauth_certbot_name,
      certbot_domains: V.cpauth_domains,
    },
  },
  {
    name: "Add cpauth nginx config",
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: V.cpauth_nginxsite_name,
      nginxsite_file: "cpauth.conf",
    },
  },
] satisfies TaskFile;
