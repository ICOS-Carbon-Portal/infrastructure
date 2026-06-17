import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  restheart_basic_auth,
  restheart_certbot_name,
  restheart_domains,
  restheart_nginxsite_name,
} from "../../../lib/globals.ts";

export default [
  {
    include_role: { name: "icos.certbot2" },
    vars: {
      certbot_name: restheart_certbot_name,
      certbot_domains: restheart_domains,
    },
  },
  {
    include_role: { name: "icos.nginxsite" },
    vars: {
      nginxauth_conf: `auth_basic "Login required";
auth_basic_user_file "/etc/nginx/auth/{{ restheart_nginxsite_name }}";
`,
      nginxsite_name: restheart_nginxsite_name,
      nginxsite_file: "restheart-nginx.conf",
      nginxsite_users: [restheart_basic_auth],
    },
  },
] satisfies TaskFile;
