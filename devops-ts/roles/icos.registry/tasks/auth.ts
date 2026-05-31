import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create auth directory",
    file: {
      path: expr("registry_htpasswd_file | dirname"),
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
      name: expr("item.name"),
      password: expr("item.password"),
      // We must force this encryption, otherwise 'docker login' will fail
      // (unauthorized ...)
      crypt_scheme: "bcrypt",
    },
    loop: V.registry_users,
  },
] satisfies TaskFile;
