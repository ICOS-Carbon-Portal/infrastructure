import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create doi certificate",
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.doi_certbot_name,
      certbot_domains: V.doi_domains,
    },
  },
  {
    name: "Add doi nginx config",
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: V.doi_nginxsite_name,
      nginxsite_file: "doi.conf",
    },
  },
] satisfies TaskFile;
