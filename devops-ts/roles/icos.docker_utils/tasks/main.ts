import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    when: raw('dive_architecture in ("armv6l", "armv7l")'),
    name: "Architecture is not supported",
    debug: {
      msg: tmpl`dive is not supported on ${V.dive_architecture}`,
    },
  },
  {
    when: raw('dive_architecture not in ("armv6l", "armv7l")'),
    import_tasks: "dive.yml",
    tags: "dive",
  },
  { import_tasks: "ctop.yml", tags: "ctop" },
  { import_tasks: "lazydocker.yml", tags: "lazydocker" },
] satisfies TaskFile;
