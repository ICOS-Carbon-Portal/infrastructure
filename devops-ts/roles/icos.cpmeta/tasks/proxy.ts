import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  cpmeta_certbot_name,
  cpmeta_domains,
  cpmeta_nginxsite_name,
} from "../../../lib/globals.ts";

export default [
  {
    name: "Create cpmeta certificate",
    include_role: { name: "icos.certbot2" },
    vars: {
      certbot_name: cpmeta_certbot_name,
      certbot_domains: cpmeta_domains,
    },
  },
  {
    name: "Add cpmeta nginx config",
    include_role: { name: "icos.nginxsite" },
    vars: {
      nginxsite_name: cpmeta_nginxsite_name,
      nginxsite_file: "cpmeta.conf",
    },
  },
] satisfies TaskFile;
