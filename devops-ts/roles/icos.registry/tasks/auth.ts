import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create auth directory",
    file: {
      path: tmpl("{{ registry_htpasswd_file | dirname }}"),
      state: "directory",
    },
  },
  {
    name: "Install the passlib library",
    apt: {
      name: "python3-passlib",
    },
  },
  {
    name: "Add basic auth users",
    htpasswd: {
      path: V.registry_htpasswd_file,
      name: tmpl("{{ item.name }}"),
      password: tmpl("{{ item.password }}"),
      // We must force this encryption, otherwise 'docker login' will fail
      // (unauthorized ...)
      crypt_scheme: "bcrypt",
    },
    loop: V.registry_users,
  },
] satisfies TaskFile;
