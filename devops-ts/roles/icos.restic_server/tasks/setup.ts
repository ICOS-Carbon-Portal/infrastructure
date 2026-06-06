import {
  restic_server_data,
  restic_server_exec,
  restic_server_user,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Create restic_server directory",
    file: {
      path: restic_server_exec.dirname(),
      state: "directory",
    },
  },
  {
    name: "Create restic user",
    user: {
      name: restic_server_user,
      home: restic_server_data,
      shell: "/usr/sbin/nologin",
      system: true,
    },
  },
  {
    name: "Create restic data directory",
    file: {
      path: restic_server_data,
      state: "directory",
      owner: restic_server_user,
      group: restic_server_user,
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
