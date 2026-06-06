import { vmagent_configs } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { not } from "../../../lib/vars.ts";

const _r = register("_r");

export default [
  {
    name: "Check whether vmagent is installed",
    stat: {
      path: vmagent_configs,
    },
    register: _r,
  },
  {
    name: "Fail if vmagent isn't installed",
    fail: {
      msg: "vmagent isn't installed on this machine",
    },
    when: not(_r.stat.exists),
  },
] satisfies TaskFile;
