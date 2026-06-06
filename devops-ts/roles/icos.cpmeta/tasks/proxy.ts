import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create cpmeta certificate",
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.cpmeta_certbot_name,
      certbot_domains: V.cpmeta_domains,
    },
  },
  {
    name: "Add cpmeta nginx config",
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: V.cpmeta_nginxsite_name,
      nginxsite_file: "cpmeta.conf",
    },
  },
] satisfies TaskFile;
