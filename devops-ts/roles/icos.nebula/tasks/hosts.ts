import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { nebula_hosts_block } from "../../../lib/globals.ts";
import { iff } from "../../../lib/template.ts";

export default [
  {
    name: "Add nebula hosts to /etc/hosts",
    blockinfile: {
      marker: "# {mark} ansible / nebula",
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: iff(V.nebula_hosts_enable, nebula_hosts_block, omit),
      state: iff(V.nebula_hosts_enable, "present", "absent"),
    },
  },
] satisfies TaskFile;
