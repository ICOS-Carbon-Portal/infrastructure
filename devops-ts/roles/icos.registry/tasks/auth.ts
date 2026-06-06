import { registry_htpasswd_file, registry_users } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOverVar } from "../../../lib/loop.ts";

export default [
  {
    name: "Create auth directory",
    file: {
      path: registry_htpasswd_file.dirname(),
      state: "directory",
    },
  },
  {
    name: "Install the passlib library",
    apt: {
      name: "python3-passlib",
    },
  },
  loopOverVar<{ name: string; password: string }>(registry_users, (item) => ({
    name: "Add basic auth users",
    htpasswd: {
      path: registry_htpasswd_file,
      name: item.name,
      password: item.password,
      // We must force this encryption, otherwise 'docker login' will fail
      // (unauthorized ...)
      crypt_scheme: "bcrypt",
    },
  })),
] satisfies TaskFile;
