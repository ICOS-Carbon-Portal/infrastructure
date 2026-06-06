import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create quince user",
    user: {
      name: V.quince_user,
      home: V.quince_home.default(V.omit),
      shell: "/bin/bash",
    },
  },
  {
    name: "Create quince filestore directory",
    file: {
      path: V.quince_filestore,
      state: "directory",
      owner: V.quince_user,
      group: V.quince_user,
    },
  },
  {
    name: "Install packages",
    apt: {
      name: V.item,
    },
    loop: ["mysql-server", tmpl`openjdk-${V.quince_jdk_version}-jdk`],
  },
] satisfies TaskFile;
