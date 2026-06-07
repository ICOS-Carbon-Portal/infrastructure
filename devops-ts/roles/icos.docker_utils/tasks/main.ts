import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";
import { isIn, notIn } from "../../../lib/vars.ts";

export default [
  {
    when: isIn(V.dive_architecture, ["armv6l", "armv7l"]),
    name: "Architecture is not supported",
    debug: {
      msg: tmpl`dive is not supported on ${V.dive_architecture}`,
    },
  },
  {
    when: notIn(V.dive_architecture, ["armv6l", "armv7l"]),
    import_tasks: "dive.yml",
    tags: "dive",
  },
  { import_tasks: "ctop.yml", tags: "ctop" },
  { import_tasks: "lazydocker.yml", tags: "lazydocker" },
] satisfies TaskFile;
