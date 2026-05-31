import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Add nebula hosts to /etc/hosts",
    blockinfile: {
      marker: "# {mark} ansible / nebula",
      create: false,
      insertafter: "EOF",
      path: "/etc/hosts",
      block: tmpl("{{ nebula_hosts_block if nebula_hosts_enable else omit }}"),
      state: tmpl("{{ 'present' if nebula_hosts_enable else 'absent' }}"),
    },
  },
] satisfies TaskFile;
