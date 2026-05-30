import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create cpdata certificate",
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.cpdata_certbot_name,
      certbot_domains: V.cpdata_domains,
    },
  },
  {
    name: "Add cpdata nginx config",
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: V.cpdata_nginxsite_name,
      nginxsite_file: "cpdata.conf",
    },
  },
] satisfies TaskFile;
