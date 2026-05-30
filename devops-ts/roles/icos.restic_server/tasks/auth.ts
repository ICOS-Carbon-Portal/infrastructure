import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Add restic users",
    htpasswd: {
      path: "{{ restic_server_htpasswd }}",
      crypt_scheme: "bcrypt",
      name: "{{ item.name }}",
      password: "{{ item.password }}",
      state: "{{ item.state | default(omit) }}",
    },
    loop: "{{ restic_server_users }}",
  },
] satisfies TaskFile;
