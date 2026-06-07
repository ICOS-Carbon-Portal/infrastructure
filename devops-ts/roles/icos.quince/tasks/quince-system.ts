import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item, omit } from "../../../lib/builtins.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create quince user",
    user: {
      name: V.quince_user,
      home: V.quince_home.default(omit),
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
      name: item,
    },
    loop: ["mysql-server", tmpl`openjdk-${V.quince_jdk_version}-jdk`],
  },
] satisfies TaskFile;
