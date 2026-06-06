import {
  stiltweb_bindir,
  stiltweb_home,
  stiltweb_jre_package,
  stiltweb_username,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { stiltweb_statedir } from "../../../lib/globals.ts";

export default [
  {
    name: "Create stiltweb user",
    user: {
      name: stiltweb_username,
      state: "present",
      shell: "/bin/bash",
      home: stiltweb_home,
      groups: "docker",
      append: true,
    },
  },
  {
    name: "Create directories",
    file: {
      path: item,
      state: "directory",
      owner: stiltweb_username,
      group: stiltweb_username,
    },
    with_items: [stiltweb_statedir, stiltweb_bindir],
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
      name: stiltweb_jre_package,
    },
  },
] satisfies TaskFile;
