import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  cpauth_certbot_name,
  cpauth_domains,
  cpauth_nginxsite_name,
} from "../../../lib/globals.ts";

export default [
  {
    name: "Create cpauth certificate",
    include_role: { name: "icos.certbot2" },
    vars: {
      certbot_name: cpauth_certbot_name,
      certbot_domains: cpauth_domains,
    },
  },
  {
    name: "Add cpauth nginx config",
    include_role: { name: "icos.nginxsite" },
    vars: {
      nginxsite_name: cpauth_nginxsite_name,
      nginxsite_file: "cpauth.conf",
    },
  },
] satisfies TaskFile;
