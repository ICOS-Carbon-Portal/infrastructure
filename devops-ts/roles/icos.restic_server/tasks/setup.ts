import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create restic_server directory",
    file: {
      path: expr("restic_server_exec | dirname"),
      state: "directory",
    },
  },
  {
    name: "Create restic user",
    user: {
      name: V.restic_server_user,
      home: V.restic_server_data,
      shell: "/usr/sbin/nologin",
      system: true,
    },
  },
  {
    name: "Create restic data directory",
    file: {
      path: V.restic_server_data,
      state: "directory",
      owner: V.restic_server_user,
      group: V.restic_server_user,
    },
  },
  {
    name: "Install the passlib library",
    apt: { name: "python3-passlib" },
  },
  {
    name: "Install apache2-utils",
    apt: { name: "apache2-utils", state: "present" },
  },
] satisfies TaskFile;
