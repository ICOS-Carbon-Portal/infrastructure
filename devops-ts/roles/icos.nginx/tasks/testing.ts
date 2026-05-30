import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: 'Create basic auth users for "testing"',
    include_role: {
      name: "icos.nginxauth",
    },
    vars: {
      nginxauth_name: "testing",
      nginxauth_users: "{{ nginx_testing_users }}",
    },
    when: raw("nginx_testing_users is defined"),
  },
] satisfies TaskFile;
