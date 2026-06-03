import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create mailman certificate",
    include_role: { name: "icos.certbot2", public: true },
    vars: {
      certbot_name: V.mailman_certbot_name,
      certbot_domains: V.mailman_domains,
    },
  },
  {
    name: "Create mailmain nginx config",
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: V.mailman_nginxsite_name,
      nginxsite_file: V.mailman_nginxsite_file,
    },
  },
] satisfies TaskFile;
