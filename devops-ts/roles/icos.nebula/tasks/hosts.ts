import { type TaskFile } from "../../../lib/ansible/play.ts";
import { iff } from "../../../lib/template.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Add nebula hosts to /etc/hosts",
    blockinfile: {
      marker: "# {mark} ansible / nebula",
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: iff(V.nebula_hosts_enable, V.nebula_hosts_block, V.omit),
      state: iff(V.nebula_hosts_enable, "present", "absent"),
    },
  },
] satisfies TaskFile;
