import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { stiltweb_statedir } from "../../../lib/globals.ts";

export default [
  {
    name: "Create stiltweb user",
    user: {
      name: V.stiltweb_username,
      state: "present",
      shell: "/bin/bash",
      home: V.stiltweb_home,
      groups: "docker",
      append: true,
    },
  },
  {
    name: "Create directories",
    file: {
      path: item,
      state: "directory",
      owner: V.stiltweb_username,
      group: V.stiltweb_username,
    },
    with_items: [stiltweb_statedir, V.stiltweb_bindir],
  },
  {
    name: "Install netcdf C library",
    "ansible.builtin.package": {
      name: "netcdf-bin",
      state: "present",
    },
  },
  {
    name: "Install jre",
    apt: {
      name: V.stiltweb_jre_package,
    },
  },
] satisfies TaskFile;
