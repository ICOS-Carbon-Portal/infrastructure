import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install ncdu",
    tags: "ncdu",
    unarchive: {
      remote_src: true,
      src: V.ncdu_url,
      dest: "/usr/local/bin/",
    },
    register: "_ncdu",
    diff: false,
  },
  {
    name: "Check that ncdu is executable",
    command: tmpl("{{ _ncdu.dest }}/ncdu --version"),
    changed_when: false,
    register: "_version",
  },
  {
    name: "Which version of ncdu was installed",
    debug: { msg: tmpl("Installed {{ _version.stdout }}") },
  },
] satisfies TaskFile;
