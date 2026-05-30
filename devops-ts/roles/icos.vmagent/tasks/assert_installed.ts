import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Check whether vmagent is installed",
    stat: {
      path: V.vmagent_configs,
    },
    register: "_r",
  },
  {
    name: "Fail if vmagent isn't installed",
    fail: {
      msg: "vmagent isn't installed on this machine",
    },
    when: raw("not _r.stat.exists"),
  },
] satisfies TaskFile;
