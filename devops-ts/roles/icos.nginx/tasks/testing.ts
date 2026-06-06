import { type TaskFile } from "../../../lib/ansible/play.ts";
import { nginx_testing_users } from "../../../lib/globals.ts";
import { isDefined } from "../../../lib/vars.ts";

export default [
  {
    name: 'Create basic auth users for "testing"',
    include_role: {
      name: "icos.nginxauth",
    },
    vars: {
      nginxauth_name: "testing",
      nginxauth_users: nginx_testing_users,
    },
    when: isDefined(nginx_testing_users),
  },
] satisfies TaskFile;
