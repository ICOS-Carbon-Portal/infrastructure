import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Install jre",
    apt: {
      name: V.cpdata_jre_package,
    },
  },
  {
    name: "Create cpdata user",
    user: {
      name: V.cpdata_user,
      home: V.cpdata_home,
      shell: "/bin/bash",
    },
  },
  {
    name: "Create dataAppStorage directory (if not present), take ownership",
    file: {
      path: V.cpdata_filestorage_target,
      state: "directory",
      owner: V.cpdata_user,
      group: V.cpdata_user,
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
