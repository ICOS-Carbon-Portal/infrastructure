import { cpdata_home, cpdata_jre_package, cpdata_user } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { cpdata_filestorage_target } from "../../../lib/globals.ts";

export default [
  {
    name: "Install jre",
    apt: {
      name: cpdata_jre_package,
    },
  },
  {
    name: "Create cpdata user",
    user: {
      name: cpdata_user,
      home: cpdata_home,
      shell: "/bin/bash",
    },
  },
  {
    name: "Create dataAppStorage directory (if not present), take ownership",
    file: {
      path: cpdata_filestorage_target,
      state: "directory",
      owner: cpdata_user,
      group: cpdata_user,
    },
  },
  {
    name: "Set up logrotate for ETC facade",
    copy: {
      src: "etc-facade",
      dest: "/etc/logrotate.d/etc-facade",
    },
  },
] satisfies TaskFile;
