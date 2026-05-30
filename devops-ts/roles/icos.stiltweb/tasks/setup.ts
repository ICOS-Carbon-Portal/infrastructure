import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

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
      path: V.item,
      state: "directory",
      owner: V.stiltweb_username,
      group: V.stiltweb_username,
    },
    with_items: [V.stiltweb_statedir, V.stiltweb_bindir],
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
