import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  { import_tasks: "install.yml" },
  { import_tasks: "keys.yml" },
  { import_tasks: "reresolve.yml" },
  {
    name: "Install wg(1) overlay",
    copy: {
      src: "wg.py",
      dest: "/usr/local/bin/wg",
      mode: "+x",
    },
  },
] satisfies TaskFile;
