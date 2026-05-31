import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Add nebula hosts to /etc/hosts",
    blockinfile: {
      marker: "# {mark} ansible / nebula",
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: expr("nebula_hosts_block if nebula_hosts_enable else omit"),
      state: expr("'present' if nebula_hosts_enable else 'absent'"),
    },
  },
] satisfies TaskFile;
