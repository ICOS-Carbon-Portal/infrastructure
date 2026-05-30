import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.restheart_certbot_name,
      certbot_domains: V.restheart_domains,
    },
  },
  {
    include_role: "name=icos.nginxsite",
    vars: {
      nginxauth_conf: `auth_basic "Login required";
auth_basic_user_file "/etc/nginx/auth/{{ restheart_nginxsite_name }}";
`,
      nginxsite_name: V.restheart_nginxsite_name,
      nginxsite_file: "restheart-nginx.conf",
      nginxsite_users: [V.restheart_basic_auth],
    },
  },
] satisfies TaskFile;
