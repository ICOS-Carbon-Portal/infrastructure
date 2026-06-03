import { type TaskFile } from "../../../lib/ansible.ts";
import { isDef, V } from "../_ctx.ts";

export default [
  {
    name: 'Create basic auth users for "testing"',
    include_role: {
      name: "icos.nginxauth",
    },
    vars: {
      nginxauth_name: "testing",
      nginxauth_users: V.nginx_testing_users,
    },
    when: isDef("nginx_testing_users"),
  },
] satisfies TaskFile;
